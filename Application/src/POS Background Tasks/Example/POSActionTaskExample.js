
let main = async ({ workflow, context }) => {
    // This queue makes sure that we do not have overlapping workflow.respond() requests when timer fires at the same time as button click is still awaiting.
    let processorActive = false;
    let workflowResponses = [];
    let QueueAndAwaitWorkflowRespond = (stepName, context) => {
        return new Promise(async (resolve) => {
            workflowResponses.push({ stepname: stepName, context: context, callback: resolve });
            await responseProcessor();
        });
    }
    let responseProcessor = async () => {
        if (processorActive) {
            return;
        }
        processorActive = true;

        while (workflowResponses.length != 0) {
            response = workflowResponses.shift();
            response.callback(await workflow.respond(response.stepname, response.context));
        }

        processorActive = false;
    }

    //Business logic starts here    
    let { taskId } = await QueueAndAwaitWorkflowRespond("startBackgroundTask", context);

    let taskStatus = "";
    let TaskIsDone = new Promise(async (resolve) => {
        let checkIfDone = async () => {
            let { isDone, status } = await QueueAndAwaitWorkflowRespond("isTaskDone", { taskId: taskId });
            if (isDone) {
                taskStatus = status;
                resolve();
                return;
            }
            setTimeout(checkIfDone, 1000);
        }
        setTimeout(checkIfDone, 1000);
    });

    if (await popup.confirm("Attempt cancellation of background task?")) {
        await QueueAndAwaitWorkflowRespond("cancelBackgroundTask", { taskId: taskId });
    }

    await TaskIsDone;
    await popup.message("Background task is done with status: " + taskStatus);
};