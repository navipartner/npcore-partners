page 6060081 "NPR Adm. Scanner Stat. Factbox"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the Guest Avatar Image field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(DefaultTurnstileImageGroup)
            {
                Caption = 'Default Turnstile Image';
                field("Default Turnstile Image"; Rec."Default Turnstile Image")
                {

                    ToolTip = 'Specifies the value of the Default Turnstile Image field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(ErrorImageofTurnstileGroup)
            {
                Caption = 'Turnstile Error Image';
                field("Error Image of Turnstile"; Rec."Error Image of Turnstile")
                {

                    ToolTip = 'Specifies the value of the Turnstile Error Image field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                    Caption = 'Import guest avatar image';
                    Image = Import;
                    ToolTip = 'Executes the Import guest avatar image action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.ImportGuestAvatarImage(Rec);
                    end;
                }

                action(DeleteGuestAvatarImage)
                {
                    Caption = 'Delete guest avatar image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete guest avatar image action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                    Caption = 'Import default turnstile image';
                    Image = Import;
                    ToolTip = 'Executes the Import default turnstile image action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.ImportDefaultTurnstileImage(Rec);
                    end;
                }

                action(DeleteDefaultTurnstileImage)
                {
                    Caption = 'Delete default turnstile image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete default turnstile image action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                    Caption = 'Import turnstile error image';
                    Image = Import;
                    ToolTip = 'Executes the Import turnstile error image action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    begin
                        MMAdmissionServiceWS.ImportTurnstileErrorImage(Rec);
                    end;
                }

                action(DeleteErrorImageofTurnstile)
                {
                    Caption = 'Delete turnstile error image';
                    Image = Delete;
                    ToolTip = 'Executes the Delete turnstile error image action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
