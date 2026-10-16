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
                CFMemberRegistration: Codeunit "NPR MM CFMemberRegistration";
            begin
                if ((not XRec.Enabled) and (Rec.Enabled)) then
                    case Rec.Provider of
                        Rec.Provider::Azure:
                            begin
                                Rec.TestField(QueueName);
                                Rec.TestField(AzureStorageAccountName);
                                AzureMemberRegistration.CheckIfStorageAccountQueueExist(Rec.AzureStorageAccountName, Rec.QueueName);
                            end;
                        Rec.Provider::Cloudflare:
                            begin
                                Rec.TestField(QueueName);
                                Rec.TestField(CFWorkerBaseUrl);
                                CFMemberRegistration.ValidateWorker(Rec);
                            end;
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
            Caption = 'Partition Key';
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
        field(85; Provider; Enum "NPR MM RegistrationProvider")
        {
            Caption = 'Provider';
            DataClassification = CustomerContent;
        }
        field(100; CFWorkerBaseUrl; Text[100])
        {
            Caption = 'Cloudflare Worker Base Url';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CFMemberRegistration: Codeunit "NPR MM CFMemberRegistration";
            begin
                if (Rec.CFWorkerBaseUrl <> '') then
                    CFMemberRegistration.ValidateWorkerBaseUrl(Rec.CFWorkerBaseUrl);
            end;
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