page 6014424 "NPR Getting Started"
{
    Caption = 'Hi!';
    PageType = NavigatePage;
    
    layout
    {
        area(Content)
        {
            
            usercontrol(WelcomeWizard; "NPR Get Started Wizard")
            {
                ApplicationArea = All;;
                    
                trigger Ready()
                begin
                    CurrPage.WelcomeWizard.createlayout(TitleTxt,SubTitleTxt,ExplanationTxt,IntroTxt,IntroDescTxt,GetStartedTxt,GetStartedDescTxt,FindHelpTxt,FindHelpDescTxt);
                end;

                trigger ThumbnailClicked(selection: Integer)
                var
                    Video: Codeunit Video;
                begin
                    case selection of
                        1:
                            Video.Play('https://www.youtube.com/embed/9v-I8bz_unM');
                        2:
                            Video.Play('https://www.youtube.com/embed/jUt3Bd5diMI');
                        3:
                            Video.Play('https://www.youtube.com/embed/kHz7Hdr-H4Y');
                        
                    end;
                end;
                
                
            }
            
        }
    }
    actions
    {
        area(Creation)
        {
            action("Done")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Done!';
                InFooterBar = True; 
                Promoted = true; 
                PromotedOnly = true; 
                trigger OnAction()
                        begin 
                            CurrPage.Close(); 
                        end;
                    
            }
        }
    }
    
    var
        FindHelpDescTxt: Label 'Know where to go for information';
        FindHelpTxt: Label 'Get Assistance';
        GetStartedDescTxt: Label 'See the important first steps';
        GetStartedTxt: Label 'Get Started';
        IntroDescTxt: Label 'Get to know NP Retail';
        IntroTxt: Label 'Introduction';
        SubTitleTxt: Label 'Let''s get started';
        TitleTxt: Label 'Welcome to NP Retail';
        ExplanationTxt: Label 'Start with basic a basic introduction to NP Retail or jump right into more advanced operations.';
}