page 6014674 "NPR Endpoint List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint List';
    CardPageID = "NPR Endpoint Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Endpoint";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
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
            action(Requests)
            {
                Caption = 'Requests';
                Image = XMLFile;
                RunObject = Page "NPR Endpoint Request List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
            }
            action("Request Batches")
            {
                Caption = 'Request Batches';
                Image = XMLFileGroup;
                RunObject = Page "NPR Endpoint Req. Batch List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
            }
        }
    }
}

