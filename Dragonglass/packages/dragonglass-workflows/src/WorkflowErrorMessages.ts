// TODO: These should actually be used from somewhere
export const WorkflowErrorMessages = {
    popup: "Attempting to show a popup in the context of a completed workflow.",
    complete: "Attempting to complete a workflow that has already been completed.",
    respond: "Attempting to invoke NAV from a workflow that has been completed earlier.",
    fail: "Attempting to fail a workflow that has already been either completed or failed.",
    run: "Attempting to nest a workflow in the context of a completed workflow.",
    queue: "Attempting to queue a workflow in the context of a completely processed workflow. Queue your workflow before calling workflow.complete()."
};
