library(tidyverse)

atwood = read_csv('/Users/nick/Documents/Willamette/Summer/Cloud/pronounsproject/atwood_output.csv')
constantine = read_csv('/Users/nick/Documents/Willamette/Summer/Cloud/pronounsproject/constantine_output.csv')
orwell = read_csv('/Users/nick/Documents/Willamette/Summer/Cloud/pronounsproject/orwell_output.csv')

pronouns = c("he", "his", "him", "she", "her", "hers")

atwood_pronouns = atwood %>%
  filter(tolower(token) %in% pronouns) %>%
  mutate(book = "The Handmaid's Tale")

constantine_pronouns = constantine %>%
  filter(tolower(token) %in% pronouns) %>%
  mutate(book = "Swastika Night")

orwell_pronouns = orwell %>%
  filter(tolower(token) %in% pronouns) %>%
  mutate(book = "1984")

full_pronouns = rbind(atwood_pronouns, constantine_pronouns)

full_pronouns = rbind(full_pronouns, orwell_pronouns)

full_pronouns = full_pronouns %>%
  dplyr::select(-...1, -labeled_dependency) %>%
  mutate(token = tolower(token)) %>%
  mutate(binned_dep = case_when(
    str_detect(unlabeled_dependency, "obj") ~ "object",
    str_detect(unlabeled_dependency, "subj") ~ "subject",
    .default = "none"
  )) 

pronoun_counts = full_pronouns %>%
  group_by(token, book, binned_dep) %>%
  summarise(num_instances = n())

pronoun_sub_obj_count = pronoun_counts %>%
  filter(binned_dep != "none")

full_pronouns %>%
  group_by(token, binned_dep) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = token, y = count, fill = binned_dep)) +
  geom_col(position = "dodge")

pronoun_sub_obj_count %>%
  filter(token == "her" | token == "his") %>%
  ggplot(aes(y = num_instances, x = token, fill = binned_dep)) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(x = "Pronoun", y = "Number of Times", fill = "Subject or Object",
       title = "Use of Pronouns as Subjects/Objects in Dystopian Novels")

test = pronoun_sub_obj_count %>%
  filter(token == "her" | token == "his")

ggplot(test, aes(x = token, y = num_instances, fill = binned_dep)) +
  facet_grid(~book) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(x = "Pronoun", y = "Number of Instances", fill = "Subject or Object",
       title = "Use of Gendered Pronouns as Subjects/Objects in Dystopian Novels")



testerino = full_pronouns %>%
  group_by(token, book) %>%
  summarise(count = n()) %>%
  filter(token == "her" | token == "his")

combo = left_join(test, testerino, by = c("token" = "token", "book" = "book"))

combo = combo %>% 
  mutate(percentage_of_total = num_instances / count)

combo %>%
  ggplot(aes(x = token, y = percentage_of_total, fill = binned_dep)) +
  geom_col(position = "dodge") +
  facet_wrap(~book) +
  theme_minimal() +
  labs(x = "Pronoun", y = "Percentage of Total Usage of Pronoun",
       fill = "Subject or Object", title = "Percentage of Gendered Pronouns as Subjects/Objects of Overall Gendered Pronouns, by book")






data <- data.frame(
  token = c("her", "her", "her", "her", "her", "her", "his", "his", "his", "his", "his", "his"),
  book = c("1984", "1984", "Swastika Night", "Swastika Night", "The Handmaid's Tale", "The Handmaid's Tale",
           "1984", "1984", "Swastika Night", "Swastika Night", "The Handmaid's Tale", "The Handmaid's Tale"),
  binned_dep = c("object", "subject", "object", "subject", "object", "subject", "object", "subject", "object", "subject", "object", "subject"),
  num_instances = c(48, 110, 15, 29, 91, 190, 37, 10, 16, 15, 4, 2),
  count = c(421, 421, 105, 105, 905, 905, 1086, 1086, 690, 690, 325, 325),
  percentage_of_total = c(0.114, 0.261, 0.143, 0.276, 0.101, 0.210, 0.0341, 0.00921, 0.0232, 0.0217, 0.0123, 0.00615)
)



# print our the full dataset
full_pronouns %>% 
  group_by(token) %>%
  summarise(count = n())

# print the dataset of subjects and objects
pronoun_counts %>%
  group_by(token, binned_dep) %>%
  summarise(count = sum(num_instances)) %>%
  print(n=100)



# Create a contingency table
contingency_table <- xtabs(num_instances ~ binned_dep + token, data=data)

print(contingency_table)

# Perform the chi-squared test
chisq_test <- chisq.test(contingency_table)

# Print the results
print(chisq_test)

# look at the residuals
chisq_test$residuals



#.1984

# Create the dataset
data_1984 <- data.frame(
  token = c("her", "her", "his", "his"),
  book = c("1984", "1984", "1984", "1984"),
  binned_dep = c("object", "subject", "object", "subject"),
  num_instances = c(48, 110, 37, 10)
)

# Create a contingency table
contingency_table_1984 <- xtabs(num_instances ~ binned_dep + token, data = data_1984)

# Print the contingency table
print(contingency_table_1984)

# Perform the chi-squared test
chisq_test_1984 <- chisq.test(contingency_table_1984)

# Print the results
print(chisq_test_1984)

# print theresiduals
chisq_test_1984$residuals

