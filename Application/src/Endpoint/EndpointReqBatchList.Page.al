page 6014677 "NPR Endpoint Req. Batch List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Request Batch List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Endpoint Request Batch";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Endpoint Code field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Date field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("No. of Requests"; "No. of Requests")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Requests field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Requests action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set to Collecting action';

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec, 0);
                        CurrPage.Update;
                    end;
                }
                action("Set to Ready to Send")
                {
                    Caption = 'Set to Ready to Send';
                    Image = Approve;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set to Ready to Send action';

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec, 1);
                        CurrPage.Update;
                    end;
                }
                action("Set to Sent")
                {
                    Caption = 'Set to Sent';
                    Image = SendApprovalRequest;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set to Sent action';

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec, 2);
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    var
        EndpointManagement: Codeunit "NPR Endpoint Management";
}

