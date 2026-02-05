page 6059787 "NPR Event Subscription List"
{
    Extensible = False;
    PageType = List;

    UsageCategory = Administration;
    SourceTable = "Event Subscription";
    Caption = 'Event Subscription List';
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Subscriber Codeunit ID"; Rec."Subscriber Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Subscriber Function"; Rec."Subscriber Function")
                {

                    ToolTip = 'Specifies the value of the Subscriber Function field';
                    ApplicationArea = NPRRetail;
                }
                field("Published Function"; Rec."Published Function")
                {

                    ToolTip = 'Specifies the value of the Published Function field';
                    ApplicationArea = NPRRetail;
                }
                field("Publisher Object ID"; Rec."Publisher Object ID")
                {

                    ToolTip = 'Specifies the value of the Publisher Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Publisher Object Type"; Rec."Publisher Object Type")
                {

                    ToolTip = 'Specifies the value of the Publisher Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Type"; Rec."Event Type")
                {

                    ToolTip = 'Specifies the value of the Event Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Originating App Name"; Rec."Originating App Name")
                {

                    ToolTip = 'Specifies the value of the Originating App Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set filter to tenant subscribers")
            {
                Caption = 'Set filter to tenant subscribers';
                Image = FilterLines;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                ToolTip = 'Executes the Set filter to tenant subscribers action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    SetFilterQst: Label 'Do you want to set filter to tenant subscribers';
                    ObjFilterTxt: Label '50000..99999';
                begin
                    If not Confirm(SetFilterQst, false) then
                        exit;

                    Rec.SetFilter("Subscriber Codeunit ID", ObjFilterTxt);
                end;
            }
        }
    }
}
