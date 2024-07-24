# PronounDystopia

## Introduction

For this analysis, I aimed to answer the question, “Is there a significant difference in the use of masculine and feminine pronouns as subjects and objects in a given set of corpuses?” Specifically, I am most interested in the use of the pronouns his/her, as those pronouns are most often used as either subjects or objects in a sentence. I 

## Data and Methodology

To do this analysis, I wanted to choose three novels that are all in the same genre to see how the frequencies vary based on other factors.  The novels I am analyzing are: The Handmaid’s Tale by Margaret Atwood, Swastika Night by Katharine Burdakin, and 1984 by George Orwell. 

I chose these three novels because each novel is classified as a dystopian novel, and the author and protagonists genders are each different combinations: The Handmaid’s Tale has a female author and a female protagonist, Swastika Night has a female author and a male protagonist, and 1984 has a male author and a male protagonist. Therefore, we have a good mix of different subject matters and author/protagonist gender combinations. 

To answer this question, I have leveraged the SparkNLP and johnsnowlabs libraries for Python. I used these libraries in concert with Google’s Colab in order to perform my analysis. Once I had the data output, I saved the output to CSV files and brought them into R for further analysis and visualizations using the tidyverse. 

## Hypothesis

Two of the books, Swastika Night and The Handmaid’s Tale, deal directly with women’s reproductive rights. In both books, women have been subjugated to essentially live as livestock, existing for the sole purpose of reproduction. On the flip side, 1984 is more of a standard dystopian novel affair that does not delve into the issue of women’s reproductive rights, instead focusing on governmental oversight and conformity. 

As such, my hypothesis is: books that deal with women’s reproductive rights will have more feminine gendered pronouns used as objects as opposed to books that do not cover this issue. Additionally, I hypothesize that the percentage of gendered pronouns used as objects out of the overall use of the gendered pronouns in the book will be highest in books dealing with women’s reproductive rights. Finally, I believe that the gender of the author will not make a significant difference in the frequencies of subject/object pronouns.

## Analysis/Results

To perform my analysis, I first brought my datasets into Google Colab and imported the SparkNLP packages. I then set up a pipeline to analyze the datasets. The pipeline would assemble the document, detect the sentences, tokenize the words, get the parts of speech for each token, determine the token’s dependency, and finally, get the token’s dependency type, which can include subjects or objects. The pipeline code is as follows

```python
# Define the custom NLP pipeline
document_assembler = DocumentAssembler() \
    .setInputCol("text") \
    .setOutputCol("document")

sentence_detector = SentenceDetector() \
    .setInputCols(["document"]) \
    .setOutputCol("sentence")

tokenizer = Tokenizer() \
    .setInputCols(["sentence"]) \
    .setOutputCol("token")

pos_tagger = PerceptronModel.pretrained("pos_anc", lang="en") \
    .setInputCols(["sentence", "token"]) \
    .setOutputCol("pos")

dependency = (
            DependencyParserModel.pretrained("dependency_conllu")
            .setInputCols(["document", "pos", "token"])
            .setOutputCol("dependency")
        )
        
# New stage 2: Dependency Parsing (labeled)
dependency_label = (
            TypedDependencyParserModel.pretrained("dependency_typed_conllu")
            .setInputCols(["token", "pos", "dependency"])
            .setOutputCol("dependency_type")
        )

pipeline = Pipeline(stages=[
    document_assembler,
    sentence_detector,
    tokenizer,
    pos_tagger,
    dependency,
    dependency_label
])

```

I then ran my datasets through the pipeline and got the tokens, part of speech tags, and dependency types for each word in each corpus.

```python
# Apply the pipeline
model = pipeline.fit(sentences)
result = model.transform(sentences)

tokens = result.select(explode(col("token.result")).alias("token"))
pos_tags = result.select(explode(col("pos.result")).alias("pos"))
dependencies = result.select(explode(col("dependency_type.result")).alias("dependency_type"))

print(tokens.collect())
print(pos_tags.collect())
print(dependencies.collect())
```

And then… I got stuck. I was attempting to loop through the tokens field to collect every instance of a gendered pronoun, but each time I attempted to do this, Google Colab would time out and give me an error. I tried this multiple times and tried adjusting my code to make it less intensive, but I could not figure this issue out.

I spent a good amount of time looking up possible solutions, when I came to the most obvious solution of all: johnsnowlabs. johnsnowlabs, in all their glory, created their own library of SparkNLP packages to perform common actions in a single line. This includes a pipeline to determine the dependencies for a given corpus. As such, I ended up tossing all of my code from above (but wanted to still include it because I worked hard on it), and going with the following code.

```python
orwell = open("orwell.txt").read()

output = nlp.load("dep").predict(orwell)

output.to_csv("orwell_output.csv")
```

The following code would essentially do everything that I manually coded above, but the difference is that this code didn’t time out Google Colab (did take it around 20 minutes to run for each corpus). Once I had all the data I needed, I brought it into R for further analysis and visualizations. 

I filtered down the dataset to only include the pronouns ‘his’ or ‘her’, the dependency type (so I could determine if the pronoun was a subject or object), and the corpus that the pronoun came from. I then counted the instances of each pronoun and dependency combination that appeared in the corpuses, and created the following graphic. 

![Graphic 1: Gendered Pronoun usages in Dystopian Novels, split by subject or object and book](https://prod-files-secure.s3.us-west-2.amazonaws.com/eb0b00f7-6676-4d32-966d-8eec9499b05c/04543dae-aba4-40a9-bbdc-44090347b547/Untitled.png)

Graphic 1: Gendered Pronoun usages in Dystopian Novels, split by subject or object and book

This graphic is very elucidating. First off, all three novels have higher uses of feminine pronouns (her) than masculine pronouns (his), which is very interesting, and not a result that I would have anticipated. Secondly, the gendered pronoun ‘his’ is used more often as an object as opposed to a subject of a sentence, which is not what I would have expected to see. 

However, raw counts can be very misleading, as it doesn’t take into account the entire picture. Take The Handmaid’s Tale for example; only 4 times was ‘his’ used as an object and only 2 times was ‘his’ used as a subject. To account for this, I compared the rates of pronoun usages as subjects and objects compared to the overall use of the pronoun in each corpus.

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/eb0b00f7-6676-4d32-966d-8eec9499b05c/e98c478e-26bf-4301-b9b3-c25f3beb24f8/Untitled.png)

This helps clear things up. We can clearly see that the feminine pronouns are used at far higher rates as subjects and objects of sentences as compared with the masculine pronouns. In fact, all 3 corpuses have feminine pronouns used as objects over 10% of the total instances of the feminine pronouns, while no corpus’s masculine pronouns used as objects crack even 5%. 

To determine the statistical significance of these values, I ran a Chi Squared test on the entire dataset to see if the differences between subjects and objects for his and her are statistically significant. Running a Chi Squared test, I got a value of p = 6.7e-10, which confirms that the differences that I am seeing in the rates of masculine and feminine pronouns as subjects/objects is statistically significant. 

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/eb0b00f7-6676-4d32-966d-8eec9499b05c/de4e6e6f-cebd-4760-9bf2-c81134635701/Untitled.png)

Moreover, delving into the chi square test’s residuals, it is clear to see that the use of ‘his’ as an object is much higher than the expected frequency, while the use of ‘her’ as an object is much lower than the expected frequency. 

## Conclusion

In conclusion, the difference between masculine and feminine pronoun usages as subjects and objects is statistically significant. Additionally, the rate at which feminine pronouns are used as subjects or objects is much greater than the rate at which masculine pronouns are used as subjects or objects. 

Additionally, the gender of the author and main character didn’t seem to play much of a role on the use of pronouns as subjects or objects. It did play a small role in the number of instances of the pronoun used, but not as big of an effect as I had hypothesized.

One possible limitation is in the use of the dependency type to determine subject/object. Given that the rates of SparkNLP perceiving ‘her’ as subjects/objects is much greater than the rates of SparkNLP perceiving ‘his’ as subjects/objects, there could be something at play with the SparkNLP dependency modelling itself. It could simply struggle more with identifying masculine pronouns than feminine pronouns. This is a possible explanation, and would be an interesting avenue for further research.
