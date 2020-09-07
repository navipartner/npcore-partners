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
                }
                field("Endpoint Code"; "Endpoint Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("No. of Requests"; "No. of Requests")
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
                RunPageLink = "Request Batch No." = FIELD("No.");
                ApplicationArea=All;
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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

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

