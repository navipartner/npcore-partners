page 6151531 "NPR Nc Collection List"
{
    Caption = 'Nc Collection List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collection";
    UsageCategory = Lists;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Collector Code"; Rec."Collector Code")
                {

                    ToolTip = 'Specifies the value of the Collector Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Creation Date"; Rec."Creation Date")
                {

                    ToolTip = 'Specifies the value of the Creation Date field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("No. of Lines"; Rec."No. of Lines")
                {

                    ToolTip = 'Specifies the value of the No. of Lines field';
                    ApplicationArea = NPRNaviConnect;
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

                ToolTip = 'Executes the Lines action';
                ApplicationArea = NPRNaviConnect;
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

                    ToolTip = 'Executes the Set to Collecting action';
                    ApplicationArea = NPRNaviConnect;

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

                    ToolTip = 'Executes the Set to Ready to Send action';
                    ApplicationArea = NPRNaviConnect;

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

                    ToolTip = 'Executes the Set to Sent action';
                    ApplicationArea = NPRNaviConnect;

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

