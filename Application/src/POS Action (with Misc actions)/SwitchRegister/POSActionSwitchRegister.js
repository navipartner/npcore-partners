let isWorkflowDisabled = async ({ workflow }) => {
  try {
    const result = await workflow.respond("is_workflow_disabled");
    return result || false;
  } catch (err) {
    console.error("[SwitchRegister] Permission check failed:", err);
    return true;
  }
};

let main = async ({ workflow, customList, toast, captions }) => {
    try {
        const selectedPosUnitStr = await customList.setParameters({
            topic: "POS_UNIT",
            maxPageSize: 50,
            title: captions.selectPOSUnitTitle,
        });

        if (selectedPosUnitStr) {
            const selectedPosUnit = JSON.parse(selectedPosUnitStr);
            const selectedUnitNo = selectedPosUnit.fields?.["1"];

            if (!selectedUnitNo) {
                return " ";
            }

            await workflow.respond("EnterRegister", {
                RegisterNo: selectedUnitNo,
            });

        } else {
            return " ";
        }
    } catch (err) {
        console.error("[SwitchRegister] Unexpected error:", err);
        toast.error(err?.message || "An unexpected error occurred", { 
            title: "Unable to Complete Action", 
            hideAfter: 5 
        });
        return " ";
    }
}