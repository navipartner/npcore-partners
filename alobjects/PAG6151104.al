page 6151104 "NpRi Party Types"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Party Types';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpRi Party Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Table No.";"Table No.")
                {
                    ShowMandatory = true;
                }
                field("Table Name";"Table Name")
                {
                }
                field("Reimburse every";"Reimburse every")
                {
                }
                field("Next Posting Date Calculation";"Next Posting Date Calculation")
                {
                }
            }
        }
    }

    actions
    {
    }
}

