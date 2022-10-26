# Kanban boards in DevOps Azure

Kanban boards provide users with means of easily and effectively managing various types of assignments, and following their progress from [creation](../howto/link_assignment_to_cs.md) up until completion. 

The following types of assignments exist in our version of the Kanban board, in the order of hierarchy: 

- **Epics** - High-level efforts in the product-building process that consist of features.
- **Features** - They define new functionalities that need to be created to achieve the goal of the epic. Features consist of stories and tasks.
- **Stories** - They explain what needs to be done in non-technical terms. They are usually the source of information for clients who requested the feature.
- **Tasks** - They cover the technical aspects of an assignment.

Each column in a Kanban board represents a different stage in the assignment's progress. In our project, we use the following structure: 

| Column Name  | Description |
| ------ | ------ |
| **Backlog** | All assignments are created in this column. Once their priority is assessed, they can be moved to the **To-do** column.  |
| **To-do**  | This column contains all assignments that were created, but not yet taken up. These assignments need to be done as soon as possible, and their priority should be stated. |
| **Doing** | This column consists of all assignments that are currently being worked on. |
| **Ready for test/approval** | Assignments are moved to this column as soon as they are ready for client testing/approval. They remain in this column until their resolution is either approved or rejected. Note that each assignment you move to this column needs to contain testing instructions in its comments/description. |
| **Approved** | Once approved by clients, assignments are moved to this column, waiting to be published to the production. | 
| **Resolved on prod** | The completed assignment is resolved in the production environment. At this stage, clients may choose to perform some sort of UAT before moving the assignment to the **Closed** column. |
| **Closed** | This column is used for storing completed and approved assignments, as well as assignments that have otherwise been selected not to be worked on/deleted. | 

Additionally, each assignment may contain tasks, stories, and subtasks linked to it. You can create them either from the board or from the [assignment's](assignment_structure.md) **Related Work** section. 

## Filtering

There are multiple uses of the filtering feature, but the goal is always to find specific assignments. Here are some of the common uses:

As soon as you create or generate tags with some relevant information, such as the case ID, you can perform the board filtering according to these tags.

It is possible to filter based on cases assigned to yourself using the **@Me** option in the **Assigned to** filter. You can also provide a colleague's name in the same filter, to retrieve all assignments they are working on. 

You can also filter assignment types. Since assignments need to be interlinked, and **Story** is the most important one for informative purposes (both for clients and employees), only filtering through **User Stories** is available, to make the process faster. 

If you wish to limit the filtering results to assignments that were performed as parts of specific iterations/areas, use the **Iteration** and **Area** filters. 

### Related links

- [Assignment structure](assignment_structure.md)
