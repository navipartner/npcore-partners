# Contributor guide 
This document guides you through the process of standardizing and delivering documentation that complies with our users' needs.

It's recommended that you read through the whole guide as a part of the onboarding process for delivering documentation, but its main purpose is that of a reference which you can turn to whenever you're not sure how to structure your topics. If you have dilemmas about the technical side of the documentation process, refer to the Technical Guide.

 ## Before you start writing a new topic, ask yourself...

> [!IMPORTANT]
> If you're writing a topic for the first time, it's highly recommended that you first watch [the video](https://documentation.divio.com/) on documentation framework that we based our own on.

- **What do the readers wish to accomplish?**   
  Some users read documentation because they need help in achieving a certain goal, while others need to get acquainted with the product or its individual functionalities. These two groups of people require completely different types of documentation. 
- **How will the customer find the content?/What search terms will the reader use?**  
  Plan for search keyword optimization when writing.
- **How many topics does the feature require?**   
  It's important to plan ahead and not to put too much information into a single topic. Typically, readers lose focus after a while, so it's important to keep them engaged.

> [!NOTE]
> The purpose of these questions is to help give you a better picture of how the topic/section needs to look like to provide the best user experience.

## Rules for writing documentation

- **Use standard English (United States (U.S.)**  
  When in doubt, refer to the [Merriam-Webster Dictionary](https://www.merriam-webster.com/), but the spell checker plugin should automatically take care of all language-related dilemmas for you.
- **Write in second person**  
  Address the reader directly (benefits: friendly tone, shorter sentences, avoids being gender-specific).
- **Use consistent terminology**  
  We will create a glossary that you can refer to when you need reassurance.
- **Test the validity of information**  
  Don't write from memory no matter how familiar with the subject you are. It's absolutely necessary to perform testing in the app before or during the writing.

## Documentation sections and structure
There are two topic structures that you can choose from, depending on the subject, knowledge levels, and the goal of the reader.

### How-to guides (Procedures)
By its nature, a how-to guide is problem-oriented and has a clear trajectory. It addresses a specific question. It shows the reader - who can be assumed to have some basic knowledge already - how to achieve their goal.  

How-to guides should consist of a short description and a procedure divided into 15 steps at most. Each step can have a step result, if necessary. 

> [!IMPORTANT] 
> The how-to topics can contain screenshots, but they should be replaced with textual instructions whenever possible.

### Guidelines for writing how-to guides (procedures)
 
 - Focus on answering a single question or completing a single task.
 - Name the guide well. The name should tell the reader exactly what the guide does.
 - Provide a series of steps.
 - Don't explain concepts.
 
 Follow this structure:  
  
![How-to structure](images\embedded_how_to_guide_contributor_auto_x2_colored.jpg)

 **Short description**  
 The short description should contain some basic information about the topic subject. Effective short descriptions provide enough context for a reader to understand what the topic conveys. It preferably contains keywords which help the reader to identify whether the topic contains information that's relevant to them. It should consist of no longer than two sentences. 

 **Context (if necessary)**  
 Context provides a background explanation of the task. This information helps the user understand what the purpose of the task is and what they gain by completing it. This section doesn't replace the explanation topic, although it might include some conceptual information.

 **Procedure:**
 The procedure contains information specific to completing a task. It contains a series of steps that the user must follow to accomplish the task. At least two steps are required inside a single procedure. Each step should begin with a number that determines its order within the entire procedure. 

 Other than steps, the procedure should contain step results, contextual information, screenshots or important notes that relate to the step.

 - step result - provides information on the expected outcome of a step. If a user interface is documented, the outcome could describe a dialog box opening or the appearance of the progress indicator. Step results are useful to assure a user that they are on track, but shouldn't be used for every step as this quickly becomes tedious. 
 - contextual step information - used for providing additional information about the step.

 **Next steps (if necessary)**  
 If users need to complete another step or several steps immediately after completing this procedure, the steps can be added in this section which follows the main how-to procedure.
 Alternatively, the **Next steps** section can contain a link to a completely different how-to topic which should be performed after this one.


### Explanations
Explanations are understanding-oriented. They contain descriptions, explanations and illustrations which make it easier for users to understand functionalities and their purpose. Explanations should consist of a short description of the feature, followed by more detailed overview and potentially screenshots. You can also add a conclusion, but make sure that it doesn't include new information.

 #### Guidelines for writing explanations

 Follow this structure:

![Explanation structure](images\explanation_structure_plan.png)

  - Provide context.
  - Provide only the information users may be interested in; don't explain too much.
  - Write sentences that provide useful information. Sentences like "The login field is used for logging in." are unnecessary.
  - Don't instruct or provide technical reference.

## Creating screenshots
Although it's highly recommended to replace screenshots with text in documentation due to future GUI changes, it's also important to have a unified procedure and tools for taking and formatting screenshots.

A good screenshot should be focused on the point you're trying to illustrate to the target audience.
It shouldn't be too big - don't distract users with unnecessary information. Screenshots should serve as a quick illustration of the preceding sentence or paragraph, they shouldn't introduce new information. For example, if I want to indicate to users where they can find the option for changing the user language in YouTube, I would use the following screenshot:  



  ![Good screenshot example](images\Screenshot_How_To_Youtube_Example.PNG)  

The screenshot clearly indicates which part of the screen is of interest and which button needs to be clicked to achieve the desired outcome.

It also helps to frame the button that users need to find.


I recommend the [Greenshot](https://getgreenshot.org/downloads/) screenshot-capturing tool, since it's easy to use and has many useful options.

> [!NOTE]
> Avoid adding multiple screenshots one after the other. Wherever possible, try to add some text between them.

## General recommendations:

To ensure that the documentation style is unified, the following recommendations should be follow, regardless of the type of topic that you're writing. Your docs may still be valid if some of these guidelines aren't met, but it would be best to apply them to maximize the docs' usability.


- **If you can, use the present tense and active voice**  
  They are easier to read and understand. They also improve searchability.
- **Use the sentence-style capitalization in headings**  
  (For example, write "Point of sale", not "Point of Sale")
- **Write brief and meaningful text**  
  Technical documentation should cater to the users' immediate needs. Organize your content into short but meaningful sentences wherever possible.
- **Prioritize**  
  Lead with the information that matters the most, so that readers know immediately where to focus their attention.
- **Don't be abstract**  
  Basically, if you're intimately acquainted with the subject, your writing should automatically become more straight-to-the-point.
- **Avoid gender-specific language**  
  Don't use he
- **Avoid unnecessary information**  
  Put yourself in the users' shoes and separate information that you personally think is interesting, and information that users need.



  What is unnecessary information?
   - **Description of UI elements**  
   You shouldn't write about things that users can already clearly see in the app.
   - **Repetitive content**  
   There's no need to state the same thing more than once per a topic.








