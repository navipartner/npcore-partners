page 6151531 "NPR Nc Collection List"
{
    // NC2.01\BR\20160909  CASE 250447 Object created

    Caption = 'Nc Collection List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collection";
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
                field("Collector Code"; "Collector Code")
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
                field("No. of Lines"; "No. of Lines")
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
            action(Lines)
            {
                Caption = 'Lines';
                Image = XMLFile;
                RunObject = Page "NPR Nc Collection Lines";
                RunPageLink = "Collection No." = FIELD("No.");
                ApplicationArea = All;
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
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        NcCollectorManagement.SetCollectionStatus(Rec, 0);
                        CurrPage.Update;
                    end;
                }
                action("Set to Ready to Send")
                {
                    Caption = 'Set to Ready to Send';
                    Image = Approve;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        NcCollectorManagement.SetCollectionStatus(Rec, 1);
                        CurrPage.Update;
                    end;
                }
                action("Set to Sent")
                {
                    Caption = 'Set to Sent';
                    Image = SendApprovalRequest;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        NcCollectorManagement.SetCollectionStatus(Rec, 2);
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    var
        NcCollectorManagement: Codeunit "NPR Nc Collector Management";
}

