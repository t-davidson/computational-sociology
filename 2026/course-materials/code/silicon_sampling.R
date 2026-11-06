# Script to simulate answers to a GSS question using a small language model
# Model: IBM Granite 4.0 micro, official GGUF version from IBM

library(localLLM)
library(tidyverse)
library(gssr)
library(haven)

# The model (2.1 GB) is downloaded from Hugging Face on first use and cached
model <- "https://huggingface.co/ibm-granite/granite-4.0-micro-GGUF/resolve/main/granite-4.0-micro-Q4_K_M.gguf"

# To download it in advance uncomment and run this line once
# download_model(model)

# Question ----

# To use another question, change these two lines. Check that it was asked in
# 2024 and find the wording at https://gssdataexplorer.norc.org/variables/vfilter
# or https://kjhealy.github.io/gssrdoc/
item <- "aiworry"
question <- "Overall, how worried, if at all, are you that in the next 10 years machines, computer programs, and Artificial Intelligence (AI) will take over many of the jobs done by humans?"

# Another question: uncomment these two lines to use it instead
# item <- "discaff"
# question <- "What do you think the chances are these days that a white person won't get a job or promotion while an equally or less qualified black person gets one instead? Is this very likely, somewhat likely, or not very likely to happen these days?"

# Data ----

gss24 <- gss_get_yr(2024)

# The question and the characteristics used in the backstories
data <- gss24 |>
  select(real = all_of(item), age, sex, race, degree, polviews) |>
  mutate(across(everything(), zap_missing),
         across(-age, as_factor),
         age = as.numeric(age)) |>
  drop_na() |>
  droplevels() |>
  mutate(overall = "all respondents") # A single group, to plot everyone together

# 500 respondents who answered the question
set.seed(950)
respondents <- data |>
  slice_sample(n = 500)

# Real answers ----

# Share giving each answer within each group
# ({{ }} passes column names into the function)
plot_answers <- function(data, answer, group) {
  data |>
    count({{ group }}, {{ answer }}) |>
    group_by({{ group }}) |>
    mutate(share = n / sum(n)) |>
    ggplot(aes(x = share, y = {{ group }}, fill = {{ answer }})) +
    geom_col(color = "white") +
    scale_fill_viridis_d() +
    labs(x = "Share", y = NULL, fill = NULL) +
    theme_minimal()
}

plot_answers(respondents, real, overall)
plot_answers(respondents, real, polviews)
plot_answers(respondents, real, degree)

# Prompts ----

# Each respondent's backstory is the system prompt
respondents <- respondents |>
  mutate(backstory = paste0("You are a person with the following characteristics.",
                            "\n\nAge: ", age,
                            "\nSex: ", sex,
                            "\nRace: ", race,
                            "\nEducation: ", degree,
                            "\nPolitical views: ", polviews))

cat(respondents$backstory[1])

# The question and its numbered options are the user prompt
options <- levels(respondents$real)
numbered <- paste0(seq_along(options), ". ", options, collapse = "\n")
prompt <- paste0(question, "\n\n", numbered, "\n\nAnswer with the number of your choice only.")

cat(prompt)

# Simulation ----

# hash and verbosity settings keep the console quiet
simulate <- function(backstory) {
  quick_llama(prompt, system_prompt = backstory, model_path = model,
              max_tokens = 5, clean = TRUE, hash = FALSE, verbosity = -1)
}

# A single respondent
simulate(respondents$backstory[1])
respondents$real[1]

# All 500 respondents: the number in each response picks out an option
results <- respondents |>
  mutate(response = map_chr(backstory, simulate, .progress = TRUE),
         choice = as.integer(str_extract(response, "\\d+")),
         silicon = factor(options[choice], levels = levels(real)))

# What did the model say?
results |> count(response, sort = TRUE)

# Simulated answers ----

plot_answers(results, silicon, overall)
plot_answers(results, silicon, polviews)
plot_answers(results, silicon, degree)

# Real vs. simulated ----

# Answers as numbers in the GSS order (for aiworry, 1 = very worried)
results <- results |>
  mutate(real_score = as.integer(real),
         silicon_score = as.integer(silicon))

# Fidelity: do simulated answers differ across groups like real ones?
results |>
  group_by(degree) |>
  summarise(real = mean(real_score),
            silicon = mean(silicon_score, na.rm = TRUE))

# ... and across individuals?
cor(results$real_score, results$silicon_score, use = "complete.obs")

# Variance (Bisbee et al.) and bias (Boelaert et al.): how spread out are the
# answers, and where are they centered?
results |>
  summarise(real_mean = mean(real_score),
            silicon_mean = mean(silicon_score, na.rm = TRUE),
            real_sd = sd(real_score),
            silicon_sd = sd(silicon_score, na.rm = TRUE))

# Extensions ----
# 1. Compare the real and simulated answers by sex or race. Which differences
#    does the model reproduce, and which does it invent?
# 2. Add temperature = 1 to quick_llama() so the model samples its answers.
#    Does the variance increase?
# 3. Reverse the order of the options (options <- rev(options)) and rerun.
# 4. Choose another GSS question (see the top of the script) and repeat.
