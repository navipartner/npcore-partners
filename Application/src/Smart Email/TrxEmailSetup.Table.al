table 6059820 "NPR Trx Email Setup"
{
    Caption = 'Transactional Email Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(3; Provider; Option)
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;
        }
        field(10; "Client ID"; Text[100])
        {
            Caption = 'Client ID';
            DataClassification = CustomerContent;
        }
        field(20; "API Key"; Text[100])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(30; "API URL"; Text[250])
        {
            Caption = 'API URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "API URL" := DelChr("API URL", '>', '/');
            end;
        }
        field(50; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TransactionalEmailSetup: Record "NPR Trx Email Setup";
            begin
                if (xRec.Default = true) and (Default = false) then
                    Error(CannotRemoveDefaultSetupErr);

                TransactionalEmailSetup.SetRange(Default, true);
                TransactionalEmailSetup.ModifyAll(Default, false, false);
            end;
        }
    }

    keys
    {
        key(Key1; Provider)
        {
        }
    }


    trigger OnInsert()
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
    begin
        TransactionalEmailSetup.SetRange(Default, true);
        if not TransactionalEmailSetup.FindFirst() then
            Default := true;
    end;

    var
        CannotRemoveDefaultSetupErr: Label 'There must be one default Setup in the system. To remove the default property from this setup, assign default to another setup.';
}

