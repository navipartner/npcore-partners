page 6059838 "NPR EFT Recon. Subscribers"
{
    Extensible = False;
    Caption = 'EFT Recon. Subscribers';
    PageType = List;
    SourceTable = "NPR EFT Recon. Subscriber";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SubscriberCodeunitID; Rec."Subscriber Codeunit ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit ID field';
                }
                field(SubscriberCodeunitName; Rec."Subscriber Codeunit Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Subscriber Codeunit Name field';
                }
                field(SubscriberFunction; Rec."Subscriber Function")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Subscriber Function field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(SequenceNo; Rec."Sequence No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
            }
        }
    }

    actions
    {
    }
}

