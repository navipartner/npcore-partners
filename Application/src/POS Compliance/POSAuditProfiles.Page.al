page 6150632 "NPR POS Audit Profiles"
{
    // NPR5.48/MMV /20181026 CASE 318028 Created object
    // NPR5.50/MMV /20190503 CASE 353807 Added "Allow Zero Amount Sales".
    // NPR5.51/MMV /20190617 CASE 356076 Added field 80
    // NPR5.51/ALPO/20190802 CASE 362747 Added field 90 "Allow Printing Receipt Copy"
    // NPR5.52/ALPO/20191004 CASE 370427 Added field 100 "Do Not Print Receipt on Sale": option to skip receipt printing on sale
    // NPR5.53/ALPO/20191022 CASE 373743 Added field 110 "Sales Ticket No. Series": moved from "Cash Register" (Table 6014401)
    // NPR5.54/BHR /20200228 CASE 393305 Set Card Page ID

    Caption = 'POS Audit Profiles';
    CardPageID = "NPR POS Audit Profile";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Audit Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Sale Fiscal No. Series"; "Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Fiscal No. Series field';
                }
                field("Credit Sale Fiscal No. Series"; "Credit Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Sale Fiscal No. Series field';
                }
                field("Balancing Fiscal No. Series"; "Balancing Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing Fiscal No. Series field';
                }
                field("Fill Sale Fiscal No. On"; "Fill Sale Fiscal No. On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fill Sale Fiscal No. On field';
                }
                field("Sales Ticket No. Series"; "Sales Ticket No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';
                }
                field("Audit Log Enabled"; "Audit Log Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Log Enabled field';
                }
                field("Audit Handler"; "Audit Handler")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Handler field';
                }
                field("Allow Zero Amount Sales"; "Allow Zero Amount Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Zero Amount Sales field';
                }
                field("Print Receipt On Sale Cancel"; "Print Receipt On Sale Cancel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Receipt On Sale Cancel field';
                }
                field("Do Not Print Receipt on Sale"; "Do Not Print Receipt on Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do Not Print Receipt on Sale field';
                }
                field("Allow Printing Receipt Copy"; "Allow Printing Receipt Copy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
                }
            }
        }
    }

    actions
    {
    }
}

