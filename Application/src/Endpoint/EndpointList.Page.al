page 6014674 "NPR Endpoint List"
{
    Extensible = False;
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint List';
    CardPageID = "NPR Endpoint Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Endpoint";
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Requests action';
                ApplicationArea = NPRRetail;
            }
            action("Request Batches")
            {
                Caption = 'Request Batches';
                Image = XMLFileGroup;
                RunObject = Page "NPR Endpoint Req. Batch List";
                RunPageLink = "Endpoint Code" = FIELD(Code);

                ToolTip = 'Executes the Request Batches action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

