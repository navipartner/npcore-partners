page 6060013 "NPR APIV1 - Magento Picture"
{
    APIGroup = 'magento';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'magentoPicture';
    EntitySetName = 'magentoPictures';
    EntityCaption = 'Magento Picture';
    EntitySetCaption = 'Magento Picture';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Magento Picture";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(sizeKb; Rec."Size (kb)")
                {
                    Caption = 'Size (kb)', Locked = true;
                }
                field(mimeType; Rec."Mime Type")
                {
                    Caption = 'Mime Type', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(lastDateModified; Rec."Last Date Modified")
                {
                    Caption = 'Last Date Modified', Locked = true;
                }
                field(lastTimeModified; Rec."Last Time Modified")
                {
                    Caption = 'Last Time Modified', Locked = true;
                }
                field(image; TempNPRBlob."Buffer 1")
                {
                    Caption = 'Image', Locked = true;
                }
                field(magentoUrl; MagentoUrl)
                {
                    Caption = 'Magento Url', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF

            }
        }
    }

    actions
    {
    }

    var
        TempNPRBlob: Record "NPR BLOB buffer" temporary;
        MagentoSetup: Record "NPR Magento Setup";
        MagentoUrl: Text;

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

    trigger OnOpenPage()
    begin
        MagentoSetup.Get();
    end;

    trigger OnAfterGetRecord()
    var
        OStr: OutStream;
    begin
        BuildMagentoUrl();
        // get Media fields
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

    local procedure BuildMagentoUrl()
    begin
        Clear(MagentoUrl);
        if Rec.Name = '' then
            exit;
        MagentoUrl := MagentoSetup."Magento Url" + 'media/catalog/' + Rec.GetMagentoType() + '/api/' + Rec.Name;
    end;

}
