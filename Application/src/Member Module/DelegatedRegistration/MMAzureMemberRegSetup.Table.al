table 6060006 "NPR MM AzureMemberRegSetup"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {

        field(10; AzureRegistrationSetupCode; Code[10])
        {
            NotBlank = true;
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Enabled; Boolean)
        {
            InitValue = false;
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AzureMemberRegistration: Codeunit "NPR MM AzureMemberRegistration";
            begin
                if ((not XRec.Enabled) and (Rec.Enabled)) then begin
                    Rec.TestField(QueueName);
                    Rec.TestField(AzureStorageAccountName);
                    AzureMemberRegistration.CheckIfStorageAccountQueueExist(Rec.AzureStorageAccountName, Rec.QueueName)
                end;
            end;
        }
        field(30; MemberRegistrationUrl; Text[100])
        {
            Caption = 'Member Registration Url';
            DataClassification = CustomerContent;
        }
        field(32; TermsOfServiceUrl; Text[100])
        {
            Caption = 'Terms of Service Url';
            DataClassification = CustomerContent;
        }

        field(50; SMSTemplate; Code[10])
        {
            Caption = 'SMS Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header";
        }

        field(55; EmailTemplate; Code[10])
        {
            Caption = 'E-Mail Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header";
        }

        field(60; QueueName; Text[64])
        {
            Caption = 'Queue Name';
            DataClassification = CustomerContent;
        }

        field(65; AzureStorageAccountName; Text[24])
        {
            Caption = 'Azure Storage Account Name';
            DataClassification = CustomerContent;
        }
        field(70; EnableDequeuing; Boolean)
        {
            Caption = 'Enable Dequeuing';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ((not XRec.EnableDequeuing) and (Rec.EnableDequeuing)) then
                    Rec.TestField(Enabled);
            end;
        }

        field(73; DequeueUntilEmpty; Boolean)
        {
            Caption = 'Dequeue Until Empty';
            DataClassification = CustomerContent;
        }

        field(74; DequeueBatchSize; Integer)
        {
            Caption = 'Dequeue Batch Size';
            DataClassification = CustomerContent;
            InitValue = 5;
            MinValue = 1;
            MaxValue = 100;
        }

        field(80; AllowAnonymousWallet; Boolean)
        {
            Caption = 'Allow Anonymous Wallet';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; AzureRegistrationSetupCode)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; AzureRegistrationSetupCode, Description) { }
    }

}