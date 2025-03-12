page 6184895 "NPR SG TicketProfile"
{
    Extensible = false;

    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR SG TicketProfile";
    Caption = 'Speedgate Ticket Profile';

    layout
    {
        area(Content)
        {
            field("Code"; Rec."Code")
            {
                ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                ApplicationArea = NPRRetail;
                NotBlank = true;
            }
            field(Description; Rec.Description)
            {
                ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                ApplicationArea = NPRRetail;
            }
            field(PermitTicketRequestToken; Rec.PermitTicketRequestToken)
            {
                ToolTip = 'Specifies whether the Ticket Request Token is accepted as scannable for admission.', Comment = '%';
                ApplicationArea = NPRRetail;
            }
            field(ListBias; Rec.ValidationMode)
            {
                ToolTip = 'Specifies the value of the ListBias field.', Comment = '%';
                ApplicationArea = NPRRetail;
            }

            part(TicketProfileLines; "NPR SG TicketProfileLine")
            {
                Caption = 'Ticket Profile Lines';
                ApplicationArea = NPRRetail;
                SubPageLink = Code = field("Code");
                SubPageView = sorting(Code, LineNo);
            }
        }
    }

}