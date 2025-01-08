page 6184926 "NPR SG ImageProfileCard"
{
    Extensible = false;

    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR SG ImageProfile";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(SuccessTimeout; Rec.SuccessTimeout)
                {
                    ToolTip = 'Specifies the value of the Success Timeout (ms) field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ErrorTimeout; Rec.ErrorTimeout)
                {
                    ToolTip = 'Specifies the value of the Error Timeout (ms) field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(SpeedGateImageSetupFactBox; "NPR SG ImageProfileCardPart")
            {
                Caption = 'Images';

                SubPageLink = "Code" = FIELD("Code");
                ApplicationArea = NPRRetail;
            }
        }

    }

}