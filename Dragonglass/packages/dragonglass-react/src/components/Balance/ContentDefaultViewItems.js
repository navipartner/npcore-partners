export const contentItems = {
  primaryDataItems: [
    {
      property: "calculatedAmount",
    },
    {
      property: "countedAmount",
      type: "number",
      isEditable: true,
    },
    {
      property: "difference",
      type: "number",
      isEditable: true,
    },
  ],
  closingAndTransferItems: [
    {
      property: "floatAmount",
      type: "number",
    },
    {
      property: "transferredAmount",
      type: "number",
    },
    {
      property: "calculatedAmount",
      type: "number",
    },
    {
      property: "newFloatAmount",
      type: "number",
      isEditable: true,
    },
  ],
  bankDepositItems: [
    {
      property: "bankDepositAmount",
      type: "number",
      isEditable: true,
    },
    {
      property: "bankDepositBinCode",
      type: "lookup",
      isEditable: true,
    },
    {
      property: "bankDepositReference",
      type: "text",
      isEditable: true,
    },
  ],
  moveToBinItems: [
    {
      property: "moveToBinAmount",
      type: "number",
      isEditable: true,
    },
    {
      property: "moveToBinNo",
      type: "lookup",
      isEditable: true,
    },
    {
      property: "moveToBinTransId",
      type: "text",
      isEditable: true,
    },
  ],
};
