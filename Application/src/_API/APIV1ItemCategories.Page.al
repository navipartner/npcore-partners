page 6014537 "NPR APIV1 - Item Categories"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'itemCategory';
    EntitySetName = 'itemCategories';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Category";

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
                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Code));
                    end;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Description', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }

                field(parentCategory; Rec."Parent Category")
                {
                    Caption = 'Parent Category', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Parent Category"));
                    end;
                }

                field(presentationOrder; Rec."Presentation Order")
                {
                    Caption = 'Presentation Order', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Presentation Order"));
                    end;
                }

                field(hasChildren; Rec."Has Children")
                {
                    Caption = 'Has Children', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Has Children"));
                    end;
                }

                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Indentation));
                    end;
                }

                field(nprItemTemplateCode; Rec."NPR Item Template Code")
                {
                    Caption = 'Item Template Code', Locked = true;
                }

                field(nprMainCategory; Rec."NPR Main Category")
                {
                    Caption = 'Main Category', Locked = true;
                }

                field(nprMainCategoryCode; Rec."NPR Main Category Code")
                {
                    Caption = 'Main Category Code', Locked = true;
                }

                field(nprBlocked; Rec."NPR Blocked")
                {
                    Caption = 'Blocked', Locked = true;
                }

                field(nprGlobalDimension1Code; Rec."NPR Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }

                field(nprGlobalDimension2Code; Rec."NPR Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
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

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        ItemCategory.SetRange(Code, Rec.Code);
        if not ItemCategory.IsEmpty() then
            Rec.Insert();

        Rec.Insert(true);

        RecRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, CurrentDateTime());
        RecRef.SetTable(Rec);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.GetBySystemId(Rec.SystemId);

        if Rec.Code = ItemCategory.Code then
            Rec.Modify(true)
        else begin
            ItemCategory.TransferFields(Rec, false);
            ItemCategory.Rename(Rec.Code);
            Rec.TransferFields(ItemCategory);
        end;
    end;

    var
        TempFieldSet: Record Field temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::"Item Category", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"Item Category";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}






