page 6014677 "Endpoint Request Batch List"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Request Batch List';
    Editable = false;
    PageType = List;
    SourceTable = "Endpoint Request Batch";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field("Endpoint Code";"Endpoint Code")
                {
                }
                field(Status;Status)
                {
                }
                field("Creation Date";"Creation Date")
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("No. of Requests";"No. of Requests")
                {
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
                RunObject = Page "Endpoint Request List";
                RunPageLink = "Request Batch No."=FIELD("No.");
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

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec,0);
                        CurrPage.Update;
                    end;
                }
                action("Set to Ready to Send")
                {
                    Caption = 'Set to Ready to Send';
                    Image = Approve;

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec,1);
                        CurrPage.Update;
                    end;
                }
                action("Set to Sent")
                {
                    Caption = 'Set to Sent';
                    Image = SendApprovalRequest;

                    trigger OnAction()
                    begin
                        EndpointManagement.SetBatchStatus(Rec,2);
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    var
        EndpointManagement: Codeunit "Endpoint Management";
}

