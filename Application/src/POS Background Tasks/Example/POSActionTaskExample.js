
let main = async ({ workflow, context }) => {
    let { taskId } = await workflow.respond("startBackgroundTask", context);

    let taskStatus = "";
    let TaskIsDone = new Promise(async (resolve) => {
        let checkIfDone = async () => {
            let { isDone, status } = await workflow.respond("isTaskDone", { taskId: taskId });
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
        await workflow.respond("cancelBackgroundTask", { taskId: taskId });
    }

    await TaskIsDone;
    await popup.message("Background task is done with status: " + taskStatus);
};