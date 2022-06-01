# Contributor guide 

# Table of contents

1. [What is technical documentation](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=what-is-technical-documentation%3F)
2. [Before you start writing...](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=before-you-start-writing%2C-ask-yourself...)
3. [Rules](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=rules-for-writing-documentation)
4. [How-to guides](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=how-to-guides-(procedures))
5. [Explanations](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=explanations)
6. [Screenshots](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=creating-screenshots)
7. [In-app tooltips](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=defining-tooltips)
8. [General recommendations](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=general-recommendations)


# What is technical documentation?

Technical documentation helps end-users, administrators, colleagues, or technicians use your product, understand your processes, and get unstuck. It needs to be clear, searchable, and useful. In NaviPartner, we aim to write two types of documents - [how-to guides](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=how-to-guides-(procedures)) and [explanations](https://navipartner.visualstudio.com/_git/NpCore?path=/Documentation/internal/ContributorGuide.md&anchor=explanations).    

## What is the purpose of this guide?

The guide was created to ensure that you have material you can turn to whenever you're not sure how to approach a certain writing task.

If you have questions about the technical side of the documentation process, refer to the [Technical Guide](./TechnicalGuide.md), or ping me on Teams.

## Which documentation is external?

- Instructions for setting up a certain segment of our solutions
- Explanations of publicly available solution-related concepts
- Basically anything customers ask NP employees to help them with on a regular or a semi-regular basis 

Internal documentation deals with back-end information that would be more suitable for developers or hosting. This kind of documentation should be added to the /internal/ folder exclusively.

 ## Before you start writing, ask yourself...

> [!IMPORTANT]
> It's highly recommended that you first watch [the video](https://documentation.divio.com/) on documentation framework that we used to model our own.

- **What do the readers wish to accomplish?**   
  Some users read documentation because they need help in achieving a certain goal, while others need to get acquainted with the product or its individual functionalities. These two groups of people require completely different types of documentation. 
- **How will the customer find the content?/What search terms will the reader use?**  
  Plan for search keyword optimization when writing.
- **How many topics does the feature require?**   
  It's important to plan ahead and not to put too much information into a single topic. Typically, readers lose focus after a while, so it's important to keep them engaged.

## Rules for writing documentation

- **Use standard English (United States (U.S.)**  
  When in doubt, refer to the [Merriam-Webster Dictionary](https://www.merriam-webster.com/).
- **Write in second person**  
  Address the reader directly (benefits: friendly tone, shorter sentences, avoids being gender-specific).
- **Use consistent terminology**  
  Stick to the publicly-known, widespread terms.
- **Test the validity of information**  
  Don't write from memory no matter how familiar with the subject you are. It's absolutely necessary to perform testing in the app before or during the writing.
- **All GUI elements should be written in the bold font**   
  You shouldn't indicate that something is a GUI element by using quotation marks.  
- **Add screenshots ONLY when they add value to the article/topic**   
  If it's quicker to point readers' attention to something by providing an image, go for it. Otherwise, stick to textual explanations. If we have too many screenshots and the GUI is changed, we will have to replace all screenshots manually.

# Documentation sections and structure
There are two topic structures that you can choose from, depending on the subject, knowledge levels, and the goal of the reader.

## How-to guides (Procedures)
A how-to guide is problem-oriented and has a clear trajectory. It addresses a specific question, and shows the reader - who can be assumed to have some basic knowledge already - how to achieve their goal.  

How-to guides should consist of a short description and a procedure divided into 15 steps at most. Each step can have a step result, if necessary. 

## Guidelines for writing how-to guides (procedures)
 
 - Focus on answering a single question or completing a single task.
 - Name the guide well. The name should tell the reader exactly what the guide does.
 - Provide a series of steps organized as a numbered list, not as bullet points.
 - Don't explain concepts.
 - Begin the optional steps with (Optional), so that users can immediately identify them as such.
 
## How-to guide segments

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

 ### How-to guide - example

![How-to structure](images/embedded_how_to_guide_contributor_auto_x2_colored.jpg)

## Explanations
Explanations are understanding-oriented. They contain descriptions, explanations and illustrations which make it easier for users to understand functionalities and their purpose. Explanations should consist of a short description of the feature, followed by more detailed overview and potentially screenshots. You can also add a conclusion, but make sure that it doesn't include new information.

 ## Guidelines for writing explanations

  - Provide context.
  - Provide only the information users may be interested in; don't explain too much.
  - Write sentences that provide useful information. Sentences like "The login field is used for logging in." are unnecessary.
  - Don't instruct or provide technical reference.
  - Avoid using numbered lists when there's no chronological order or listed items. 

  ![Explanation structure](images/explanation_picture.png)

## Creating screenshots
Although it's highly recommended to replace screenshots with text in documentation due to future GUI changes, it's also important to have a unified procedure and tools for taking and formatting screenshots.

A good screenshot should be focused on the point you're trying to illustrate to the target audience.
It shouldn't be too big - don't distract users with unnecessary information. Screenshots should serve as a quick illustration of the preceding sentence or paragraph, they shouldn't introduce new information. For example, if I want to indicate to users where they can find the option for changing the user language in YouTube, I would use the following screenshot:  


  ![Good screenshot example](images/screenshot_example.png)  

The screenshot clearly indicates which part of the screen is of interest and which button needs to be clicked to achieve the desired outcome.

It also helps to frame the screenshot with a subtle dark-grey frame and put a smaller, red frame around the button that users need to find.

> [!NOTE]
> Avoid adding multiple screenshots one after the other. Wherever possible, try to add some text between them.

I use the following tools for capturing and editing screenshots:

- [Sniptool](https://www.reasyze.com/sniptool/) for capturing screenshots. Sniptool also has a really friendly editor.
- [Paint.net](https://www.getpaint.net/) for cropping screenshots and framing important segments.


## Defining tooltips

[Tooltips](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/onboarding-teaching-tips-tours) are user-targeted messages that provide descriptions or explanations of fields and action in the GUI. 
When constructing tooltips, we're going to strive for the model defined by the Business central style guide. This model includes the following:

- If the control is a field, begin the tooltip with "Specifies".
- If the control is an action, begin with a verb in the imperative form, such as "Calculate" or "View".
- Include the most valuable information that users need to perform the task that the field or action supports.        
  For example, for the Post action, do not write Post the document. Write, for example, Update ledgers with the amounts and quantities on the document or journal lines.
- Describe complex options in tooltips for option fields. 
- Try not to exceed 200 characters including spaces.
- Don't use line breaks in the tooltip text.

## General recommendations

To ensure that the documentation style is standardized, the following recommendations should be considered, regardless of the type of topic that you're writing. Your docs may still be valid if some of these guidelines aren't met, but it would be best to apply them to maximize the docs' usability.


- **If you can, use the present tense and active voice.**  
  They are easier to read and understand. They also improve searchability.
- **Don't use abbreviations.**   
  Instead of "e.g.", use "for example", "such as", or "like". The same goes for all other abbreviations ("etc." -> "and so on"; "i.e." -> "that is").
- **Use the sentence-style capitalization in headings.**  
  (For example, write "Point of sale", not "Point of Sale")
- **Write brief and meaningful text.**  
  Technical documentation should cater to the users' immediate needs. Organize your content into short but meaningful sentences wherever possible.
- **Prioritize.**  
  Lead with the information that matters the most, so that readers know immediately where to focus their attention.
- **Don't be abstract.**  
  Basically, if you're intimately acquainted with the subject, your writing should automatically become more straight-to-the-point.
- **Avoid gender-specific language.**  
  Don't use he/she.
- **Avoid unnecessary information.**  
  Put yourself in the users' shoes and separate information that you personally think is interesting, and information that users need.



  What is unnecessary information?
   - **Description of UI elements**  
   You shouldn't write about things that users can already clearly see in the app.
   - **Repetitive content**  
   There's no need to state the same thing more than once per a topic.
