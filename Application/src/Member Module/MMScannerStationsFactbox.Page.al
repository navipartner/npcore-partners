page 6014652 "NPR Adm. Scanner Stat. Factbox"
{

    Caption = 'NPR MM Admis. Scanner Station Factbox';
    InsertAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR MM Admis. Scanner Stations";

    layout
    {
        area(content)
        {
            group(GuestAvatarImageGroup)
            {
                Caption = 'Guest Avatar Image';
                field("Guest Avatar Image"; Rec."Guest Avatar Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Guest Avatar Image field';
                }
            }
            group(DefaultTurnstileImageGroup)
            {
                Caption = 'Default Turnstile Image';
                field("Default Turnstile Image"; Rec."Default Turnstile Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Turnstile Image field';
                }
            }
            group(ErrorImageofTurnstileGroup)
            {
                Caption = 'Turnstile Error Image';
                field("Error Image of Turnstile"; Rec."Error Image of Turnstile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnstile Error Image field';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(GuestAvatarImage)
            {
                Caption = 'Guest Avatar Image';
                action(ImportGuestAvatarImage)
                {
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Caption = 'Import guest avatar image';
                    Image = Import;
                    ToolTip = 'Executes the Import guest avatar image action';

                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.ImportGuestAvatarImage(Rec);
                    end;
                }

                action(DeleteGuestAvatarImage)
                {
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Caption = 'Delete guest avatar image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete guest avatar image action';
                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.DeleteGuestAvatarImage(Rec);
                    end;
                }
            }

            group(DefaultTurnstileImage)
            {
                Caption = 'Default Turnstile Image';
                action(ImportDefaultTurnstileImage)
                {
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Caption = 'Import default turnstile image';
                    Image = Import;
                    ToolTip = 'Executes the Import default turnstile image action';

                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.ImportDefaultTurnstileImage(Rec);
                    end;
                }

                action(DeleteDefaultTurnstileImage)
                {
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Caption = 'Delete default turnstile image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete default turnstile image action';
                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.DeleteDefaultTurnstileImage(Rec);
                    end;
                }
            }
            group(ErrorImageofTurnstile)
            {
                Caption = 'Turnstile Error Image';
                action(ImportErrorImageofTurnstile)
                {
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Caption = 'Import turnstile error image';
                    Image = Import;
                    ToolTip = 'Executes the Import turnstile error image action';

                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.ImportTurnstileErrorImage(Rec);
                    end;
                }

                action(DeleteErrorImageofTurnstile)
                {
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    Caption = 'Delete turnstile error image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete turnstile error image action';
                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.DeleteTurnstileErrorImage(Rec);
                    end;
                }
            }
        }
    }

    var

        MMAdmissionServiceWS: Codeunit "NPR MM Admission Service WS";
}