# Script to rate the room images from Pessin and Munger (2026) with a small
# vision-language model and compare its ratings with human respondents
#
# Set the working directory to this file's location before running
#
# Setup: install Ollama (https://ollama.com/download), then run the following
# in the Terminal to download the model (4.3 GB):
#   ollama pull gemma4:e2b-it-qat

# install.packages(c("httr2", "base64enc"))
library(tidyverse)
library(httr2)
library(base64enc)

model <- "gemma4:e2b-it-qat"
data_url <- "https://raw.githubusercontent.com/kmunger/Housekeeping_SocSci_Replication/main/data/processed/cleaned_data.csv"

# Human ratings ----

# Each respondent rated five vignettes; reshape to one row per rating
survey <- read_csv(data_url, show_col_types = FALSE)

ratings <- survey |>
  select(
    response_id,
    matches("^(rooms_value|outcome_clutter|messiness|source|which_room|SES)_?\\d$")
  ) |>
  rename_with(\(x) str_replace(x, "_?(\\d)$", "__\\1"), -response_id) |>
  pivot_longer(
    -response_id,
    names_to = c(".value", "vignette"),
    names_sep = "__"
  ) |>
  rename(image_url = rooms_value, human = outcome_clutter, room = which_room)

# The experiment uses 12 room images; average the human ratings for each
rooms <- ratings |>
  group_by(image_url, room, messiness, source, SES) |>
  summarise(human = mean(human, na.rm = TRUE), n = n(), .groups = "drop") |>
  mutate(file = file.path("../data/rooms", paste0("room_", row_number(), ".png")))

# Images ----

# Download the 12 images from the authors' survey
dir.create("../data/rooms", showWarnings = FALSE)
walk2(rooms$image_url, rooms$file, \(url, file) {
  if (!file.exists(file)) download.file(url, file, mode = "wb", quiet = TRUE)
})

# Model ----

# Send an image and a prompt to the local model and return its answer
ask_model <- function(file, prompt) {
  request("http://localhost:11434/api/chat") |>
    req_body_json(list(
      model = model,
      messages = list(list(
        role = "user",
        content = prompt,
        images = list(base64encode(file))
      )),
      think = FALSE,
      stream = FALSE,
      options = list(temperature = 0, seed = 950)
    )) |>
    req_timeout(300) |>
    req_perform() |>
    resp_body_json() |>
    pluck("message", "content")
}

# Test on a single image
ask_model(rooms$file[1], "Describe this image in one sentence.")

# Question ----

# The wording respondents saw in the survey
question <- paste0(
  "On a scale from 0 to 100, how messy is the room? ",
  "Answer with the number only."
)

rooms <- rooms |>
  mutate(
    answer = map_chr(file, ask_model, prompt = question, .progress = TRUE),
    model = as.numeric(str_extract(answer, "\\d+"))
  )

rooms |> select(room, messiness, source, SES, human, model)

# Comparison ----

cor(rooms$human, rooms$model, use = "complete.obs")

ggplot(rooms, aes(x = human, y = model, color = source, shape = room)) +
  geom_abline(linetype = "dashed") +
  geom_point(size = 3) +
  scale_color_viridis_d(end = 0.8) +
  coord_equal(xlim = c(0, 100), ylim = c(0, 100)) +
  labs(x = "Human rating (mean)", y = "Model rating",
       color = "Source of mess", shape = "Room") +
  theme_minimal()

# Average ratings by experimental condition
rooms |>
  group_by(source) |>
  summarise(human = mean(human), model = mean(model, na.rm = TRUE))

# Explanations ----

# Ask the model to describe a room and to explain its rating
messiest <- rooms |> slice_max(human, n = 1) |> pull(file)

ask_model(messiest, "Describe this image in one sentence.")

# Asking for an explanation can change the rating
ask_model(messiest, paste0(
  "On a scale from 0 to 100, how messy is the room? ",
  "Give the number, then explain your rating in two sentences."
))

# Edited images ----

# Does the rating change if the room is edited? Upload a room to an image
# model in your browser (e.g. ChatGPT, Gemini, or Grok) with a prompt such as
# "Tidy this room. Change nothing else." Save the edited image in `data/rooms`
# with the name of the model and the edit, e.g. `room_2_gemini_tidy.png`
edited <- list.files("../data/rooms", pattern = "^room_\\d+_", full.names = TRUE)

edits <- tibble(file = edited) |>
  mutate(
    answer = map_chr(file, ask_model, prompt = question, .progress = TRUE),
    model = as.numeric(str_extract(answer, "\\d+"))
  )

edits |> mutate(file = basename(file)) |> select(file, model)

# Extensions ----

# 1. Change the wording of `question`. Do the model's ratings move closer to
#    the human ratings?
# 2. Use the model as a zero-shot classifier. Write a prompt that asks whether
#    the room is a kitchen or a living room, or whether the mess was made by
#    children or adults, and compare the answers with `room` and `source`.
# 3. Edit a room: add children's toys, make the room look more expensive, or
#    tidy only part of the room. Which edits change the rating?
