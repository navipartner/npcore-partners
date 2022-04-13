# Release notes guide

Release notes are intended to provide customers with brief and concise information about:

- new features/functionalities
- updates to the existing features

> [!Note]
> The plan is to include bug fixes and removed/deprecated features at some point, but this is out of scope for now.

## How to write release notes

- **Each update to our solutions should be described briefly, in one or two sentences.** All additional details should be relegated to the help portal and in-app tooltips (in case of new field descriptions).

- Use the following structures for describing the new features and updates:
  - Customers can now __________.
  - ___________ has been introduced. It allows customers to ________.
  - _________ has been improved in the following ways: __________.
  - Added ___________ which gives customers an option to __________.

- **State how the updates impact customer's work in BC.**
  - Do they have to take certain steps to make the new features visible? Are there some prerequisites or setup?
  - Which BC version is the update supported on?

> [!Tip]
> Use [this example](https://keepachangelog.com/en/1.0.0/) for reference when announcing introduction of new features to the solutions.

## Technical aspects - issues

For some background, I initially suggested that all developers who were working on new features should edit a single markdown file before each release with brief descriptions of these features. However, this approach isn't ideal for several reasons. Firstly, it would involve me constantly checking and reminding people on Teams that the release notes file is due, and this unmonitored "human" approach would inevitably result in some features not being covered. Secondly, multiple people editing a single file is tricky due to potential merge conflicts. And finally, in certain scenarios consultants would be better-suited for writing release notes entries, which comes down to the issue of us not having a product owner for each feature (I'll try to not reiterate this point too many times).

The second proposed solution was to "strongly encourage" developers to populate the Release Notes field in each PR that is of the User Story/Feature type, by making the said field mandatory. Unfortunately, this approach is also faulty, as most developers use the user story type of work items as the default one, so it would require changes in the developer processes everybody is already used to, as well. Furthermore, it would be possible to just write a single character or "/" in the Release notes field, and bypass the requirement. Finally, there's also the issue I've mentioned above - sometimes developers will point to consultants as feature experts, and thus "owners" of release notes, and involving another person in a PR (especially the one who hasn't worked like this before) could break the entire pipeline. 

## Technical aspects - solution

So, at last, we are left the following solution (again, not ideal, but probably the best option for the initial stage):

We insist on developers using the correct work item types (I don't see how we can avoid this), and increase the number of mandatory characters in the User Story work item titles/descriptions to 80, which would be enough for a really short feature summary. That way we would have release note entries like (in the example of newly introduced Dynamic Pricing written by Tim):

- Added dynamic ticket pricing which gives you full control of a ticket price over time.

When a developer assigns the correct work item type and writes a meaningful title like this one, I will be able to filter work items according to the type by the end of each month, and add descriptions to a designated release notes markdown file, which will be reviewed by Mark.

By employing this approach, we will have short, but meaningful additions to the release notes, everybody will know how to write them (both developers and consultants), and the process will be somewhat automated (mandatory fields and filtering according to the ticket type).