page 6151531 "NPR Nc Collection List"
{
    Caption = 'Nc Collection List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collection";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Collector Code"; Rec."Collector Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collector Code field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Date field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Lines field';
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
                ToolTip = 'Executes the Lines action';
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
                    ToolTip = 'Executes the Set to Collecting action';

                    trigger OnAction()
                    begin
                        NcCollectorManagement.SetCollectionStatus(Rec, 0);
                        CurrPage.Update();
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
                        NcCollectorManagement.SetCollectionStatus(Rec, 1);
                        CurrPage.Update();
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
                        NcCollectorManagement.SetCollectionStatus(Rec, 2);
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    var
        NcCollectorManagement: Codeunit "NPR Nc Collector Management";
}

