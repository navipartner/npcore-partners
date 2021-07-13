page 6014677 "NPR Endpoint Req. Batch List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Request Batch List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Endpoint Request Batch";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Endpoint Code"; Rec."Endpoint Code")
                {

                    ToolTip = 'Specifies the value of the Endpoint Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Creation Date"; Rec."Creation Date")
                {

                    ToolTip = 'Specifies the value of the Creation Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Requests"; Rec."No. of Requests")
                {

                    ToolTip = 'Specifies the value of the No. of Requests field';
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
                RunPageLink = "Request Batch No." = FIELD("No.");

                ToolTip = 'Executes the Requests action';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            group("Set Status")
            {
                Caption = 'Set Status';
                action("Set to Collecting")
                {
                    Caption = 'Set to Collecting';
                    Image = Add;

                    ToolTip = 'Executes the Set to Collecting action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec, 0);
                        CurrPage.Update();
                    end;
                }
                action("Set to Ready to Send")
                {
                    Caption = 'Set to Ready to Send';
                    Image = Approve;

                    ToolTip = 'Executes the Set to Ready to Send action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec, 1);
                        CurrPage.Update();
                    end;
                }
                action("Set to Sent")
                {
                    Caption = 'Set to Sent';
                    Image = SendApprovalRequest;

                    ToolTip = 'Executes the Set to Sent action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec, 2);
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    var
        EndpointManagement: Codeunit "NPR Endpoint Management";
}

