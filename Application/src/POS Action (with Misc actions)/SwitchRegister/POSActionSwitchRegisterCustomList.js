let main = async ({ workflow, customList, toast }) => {
    try {
        const selectedPosUnitStr = await customList.setParameters({
            topic: "POS_UNIT",
            maxPageSize: 50,
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