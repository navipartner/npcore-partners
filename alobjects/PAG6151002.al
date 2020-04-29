page 6151002 "POS Quotes"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added Customer info fields
    // NPR5.48/MHA /20181130  CASE 338208 Added Action "View POS Sales Data"
    // NPR5.51/MMV /20190820  CASE 364694 Handle EFT approvals

    Caption = 'POS Quotes';
    CardPageID = "POS Quote Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Quote Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Created at";"Created at")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Customer Type";"Customer Type")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Customer Price Group";"Customer Price Group")
                {
                }
                field("Customer Disc. Group";"Customer Disc. Group")
                {
                }
                field(Attention;Attention)
                {
                }
                field(Reference;Reference)
                {
                }
                field(Amount;Amount)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
                field("Contains EFT Approval";"Contains EFT Approval")
                {
                }
            }
            part(Control6014417;"POS Quote Subpage")
            {
                SubPageLink = "Quote Entry No."=FIELD("Entry No.");
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

                trigger OnAction()
                var
                    POSQuoteMgt: Codeunit "POS Quote Mgt.";
                begin
                    //-NPR5.48 [338208]
                    POSQuoteMgt.ViewPOSSalesData(Rec);
                    //+NPR5.48 [338208]
                end;
            }
        }
    }
}

