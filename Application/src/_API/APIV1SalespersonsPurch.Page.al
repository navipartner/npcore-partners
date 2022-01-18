page 6014636 "NPR APIV1 - Salespersons/Purch"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'apiv1SalespersonsPurchasers';
    DelayedInsert = true;
    EntityName = 'salespersonPurchaser';
    EntitySetName = 'salespersonsPurchasers';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Salesperson/Purchaser";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(commission; Rec."Commission %")
                {
                    Caption = 'Commission %', Locked = true;
                }
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.', Locked = true;
                }
                field(eMail; Rec."E-Mail")
                {
                    Caption = 'Email', Locked = true;
                }
                field(eMail2; Rec."E-Mail 2")
                {
                    Caption = 'Email 2', Locked = true;
                }
                field(privacyBlocked; Rec."Privacy Blocked")
                {
                    Caption = 'Privacy Blocked', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }
                field(jobTitle; Rec."Job Title")
                {
                    Caption = 'Job Title', Locked = true;
                }
                field(searchEMail; Rec."Search E-Mail")
                {
                    Caption = 'Search Email', Locked = true;
                }

                field(image; TempNPRBlob."Buffer 1")
                {
                    Caption = 'Image';
                }

                field(nprRegisterPassword; Rec."NPR Register Password")
                {
                    Caption = 'Register Password', Locked = true;
                }

                field(nprLockedToRegisterNo; Rec."NPR Locked-to Register No.")
                {
                    Caption = 'Locked-to Register No.', Locked = true;
                }

                field(nprMaximumCashReturnsale; Rec."NPR Maximum Cash Returnsale")
                {
                    Caption = 'Maximum Cash Returnsale', Locked = true;
                }

                field(nprSupervisorPos; Rec."NPR Supervisor POS")
                {
                    Caption = 'Supervisor POS', Locked = true;
                }

                field(nprHideRegisterImbalance; Rec."NPR Hide Register Imbalance")
                {
                    Caption = 'Hide Register Imbalance', Locked = true;
                }

                field(lastModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'Replication Counter', Locked = true;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        OStr: OutStream;
    begin
        // get Media field
        TempNPRBlob.Init();
        if Rec.Image.HasValue() then begin
            TempNPRBlob."Buffer 1".CreateOutStream(OStr);
            GetTenantMedia(Rec.Image.MediaId, OStr);
        end;
    end;

    local procedure GetTenantMedia(MediaId: Guid; var OStr: OutStream)
    var
        TenantMedia: Record "Tenant Media";
        IStr: InStream;
    begin
        TenantMedia.Get(MediaId);
        TenantMedia.CalcFields(Content);
        TenantMedia.Content.CreateInStream(IStr);
        CopyStream(OStr, IStr);
    end;

    var
        TempNPRBlob: Record "NPR BLOB buffer" temporary;
}
