page 6184925 "NPR SG ImageProfileList"
{
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR SG ImageProfile";
    Caption = 'Image Profiles ';
    CardPageId = "NPR SG ImageProfileCard";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ImageProfileCode; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(SuccessTimeout; Rec.SuccessTimeout)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Success Timeout (ms) field.', Comment = '%';
                }
                field(ErrorTimeout; Rec.ErrorTimeout)
                {
                    ToolTip = 'Specifies the value of the Error Timeout (ms) field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }


                field(ReadyImage; Rec.ReadyImage.HasValue())
                {
                    ToolTip = 'Specifies the value of the Ready Image field.', Comment = '%';
                    Caption = 'Ready Image';
                    ApplicationArea = NPRRetail;
                }
                field(SuccessImage; Rec.SuccessImage.HasValue())
                {
                    ToolTip = 'Specifies the value of the Success Image field.', Comment = '%';
                    Caption = 'Success Image';
                    ApplicationArea = NPRRetail;
                }
                field(ErrorImage; Rec.ErrorImage.HasValue())
                {
                    ToolTip = 'Specifies the value of the Error Image field.', Comment = '%';
                    Caption = 'Error Image';
                    ApplicationArea = NPRRetail;
                }
                field(TicketSuccessImage; Rec.TicketSuccessImage.HasValue())
                {
                    ToolTip = 'Specifies the value of the Ticket Success Image field.', Comment = '%';
                    Caption = 'Ticket Success Image';
                    ApplicationArea = NPRRetail;
                }
                field(MemberCardSuccessImage; Rec.MemberCardSuccessImage.HasValue())
                {
                    ToolTip = 'Specifies the value of the Member Card Success Image field.', Comment = '%';
                    Caption = 'Member Card Success Image';
                    ApplicationArea = NPRRetail;
                }
                field(WalletSuccessImage; Rec.WalletSuccessImage.HasValue())
                {
                    ToolTip = 'Specifies the value of the Wallet Success Image field.', Comment = '%';
                    Caption = 'Wallet Success Image';
                    ApplicationArea = NPRRetail;
                }
                field(CityCardSuccessImage; Rec.CityCardSuccessImage.HasValue())
                {
                    ToolTip = 'Specifies the value of the City Card Success Image field.', Comment = '%';
                    Caption = 'City Card Success Image';
                    ApplicationArea = NPRRetail;
                }
                field(AnonymousMemberAvatar; Rec.AnonymousMemberAvatar.HasValue())
                {
                    ToolTip = 'Specifies the value of the Anonymous Member Avatar field.', Comment = '%';
                    Caption = 'Anonymous Member Avatar';
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