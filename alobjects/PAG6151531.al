page 6151531 "Nc Collection List"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collection List';
    Editable = false;
    PageType = List;
    SourceTable = "Nc Collection";
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
                field("Collector Code";"Collector Code")
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
                field("No. of Lines";"No. of Lines")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Lines)
            {
                Caption = 'Lines';
                Image = XMLFile;
                RunObject = Page "Nc Collection Lines";
                RunPageLink = "Collection No."=FIELD("No.");
            }
        }
        area(processing)
        {
            group("Set Status")
            {
                action("Set to Collecting")
                {
                    Caption = 'Set to Collecting';
                    Image = Add;

                    trigger OnAction()
                    begin
                        NcCollectorManagement.SetCollectionStatus(Rec,0);
                        CurrPage.Update;
                    end;
                }
                action("Set to Ready to Send")
                {
                    Caption = 'Set to Ready to Send';
                    Image = Approve;

                    trigger OnAction()
                    begin
                        NcCollectorManagement.SetCollectionStatus(Rec,1);
                        CurrPage.Update;
                    end;
                }
                action("Set to Sent")
                {
                    Caption = 'Set to Sent';
                    Image = SendApprovalRequest;

                    trigger OnAction()
                    begin
                        NcCollectorManagement.SetCollectionStatus(Rec,2);
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    var
        NcCollectorManagement: Codeunit "Nc Collector Management";
}

