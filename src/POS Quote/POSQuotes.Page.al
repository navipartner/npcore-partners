page 6151002 "NPR POS Quotes"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer info fields
    // NPR5.48/MHA /20181130  CASE 338208 Added Action "View POS Sales Data"
    // NPR5.51/MMV /20190820  CASE 364694 Handle EFT approvals
    // NPR5.55/ALPO/20200722  CASE 392042 POS quote cleanup: removed legacy functionality with load from hardcoded fields

    Caption = 'POS Quotes';
    CardPageID = "NPR POS Quote Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Quote Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Created at"; "Created at")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Customer Type"; "Customer Type")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = All;
                }
                field("Customer Disc. Group"; "Customer Disc. Group")
                {
                    ApplicationArea = All;
                }
                field(Attention; Attention)
                {
                    ApplicationArea = All;
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Contains EFT Approval"; "Contains EFT Approval")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("View POS Sales Data")
            {
                Caption = 'View POS Sales Data';
                Image = XMLFile;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSQuoteMgt: Codeunit "NPR POS Quote Mgt.";
                begin
                    //-NPR5.48 [338208]
                    POSQuoteMgt.ViewPOSSalesData(Rec);
                    //+NPR5.48 [338208]
                end;
            }
        }
    }
}

