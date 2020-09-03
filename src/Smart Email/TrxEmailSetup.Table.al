table 6059820 "NPR Trx Email Setup"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider and Default

    Caption = 'Transactional Email Setup';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(3; Provider; Option)
        {
            Caption = 'Provider';
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;
        }
        field(10; "Client ID"; Text[100])
        {
            Caption = 'Client ID';
        }
        field(20; "API Key"; Text[100])
        {
            Caption = 'API Key';
        }
        field(30; "API URL"; Text[250])
        {
            Caption = 'API URL';

            trigger OnValidate()
            begin
                //-#346526 [346526]
                "API URL" := DelChr("API URL", '>', '/');
                //+#346526 [346526]
            end;
        }
        field(50; Default; Boolean)
        {
            Caption = 'Default';

            trigger OnValidate()
            var
                TransactionalEmailSetup: Record "NPR Trx Email Setup";
            begin
                //-NPR5.55 [343266]
                if (xRec.Default = true) and (Default = false) then
                    Error(CannotRemoveDefaultSetupErr);

                TransactionalEmailSetup.SetRange(Default, true);
                TransactionalEmailSetup.ModifyAll(Default, false, false);
                //+NPR5.55 [343266]
            end;
        }
    }

    keys
    {
        key(Key1; Provider)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
    begin
        //-NPR5.55 [343266]
        TransactionalEmailSetup.SetRange(Default, true);
        if not TransactionalEmailSetup.FindFirst then
            Default := true;
        //+NPR5.55 [343266]
    end;

    var
        CannotRemoveDefaultSetupErr: Label 'There must be one default Setup in the system. To remove the default property from this setup, assign default to another setup.';
}

