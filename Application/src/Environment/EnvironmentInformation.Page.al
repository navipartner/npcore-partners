page 6150762 "NPR Environment Information"
{
    Caption = 'NP Retail Environment Information';
    PageType = Card;
    SourceTable = "NPR Environment Information";
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Extensible = false;
#IF NOT BC17
    AboutTitle = 'About NPR Environment Information';
    AboutText = 'There are three available environments - Production, Sandbox and Demo. Production contains live business data, sandbox is a safe place to test various modules, while demo environments are best suited for demonstrations and trainings.';
#ENDIF

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Environment Type"; Rec."Environment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Environment Type. Some features in NP Retail will be enabled/disabled based on the Environment Type';
#IF NOT BC17
                    AboutTitle = 'Which Environment Type to use?';
                    AboutText = 'You can select the environment type here. Make sure that you pick Sandbox if you''re testing the feature behavior, so you don''t accidentally mess with the live data. Also, note that some features in NP Retail will be enabled/disabled based on the selected environment.';
#ENDIF
                }
                field("Environment Verified"; Rec."Environment Verified")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether a user have verified the Enviroment Type value.';
#IF NOT BC17
                    AboutTitle = 'Is the environment verified?';
                    AboutText = 'When a new company is created, the Environment Verified is deactivated. If the environment isn''t verified, the next time you sign in, you will be prompted to verify the new company environment type by selecting one of the three available options.';
#ENDIF
                }
                field("Environment Template"; Rec."Environment Template")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Environment Template. Some features in NP Retail will be enabled/disabled based on the Environment Template';
#IF NOT BC17
                    AboutTitle = 'Is this a template company?';
                    AboutText = 'When a copy of a template company is created, the new company will get the same Environment Type, and the environment will be verified without asking users on login.';
#ENDIF
                }
                field("Environment Company Name"; Rec."Environment Company Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Company Name when the Environment Type was verified.';
                    Editable = false;
#IF NOT BC17
                    AboutTitle = 'Additional information';
                    AboutText = 'Information such as company name, database ID and the tenant type can be viewed here as well. Note that you need to reauthenticate for the changes to take effect.';
#ENDIF
                }
                field("Environment Database Name"; Rec."Environment Database Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Database Name when the Environment Type was verified.';
                    Editable = false;
                }
                field("Environment Tenant Name"; Rec."Environment Tenant Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Tenant when the Environment Type was verified.';
                    Editable = false;
                }
            }
        }
    }
}
