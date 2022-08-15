# Archives de données

Cet article fournit les informations nécessaires pour comprendre comment NP retail exporte vers des archives .xml, comment ces archives .xml sont sécurisées et comment vous pouvez valider qu'elles n'ont pas été falsifiées.
## Archives d'époque

Le processus d'archivage périodique automatique s'effectue via le module de file d'attente des travaux dans Business Central.
Les archives exportées sont stockées dans un Azure Blob Storage, à l'intérieur d'un conteneur spécifique au client, sur lequel NaviPartner conserve un contrôle total.
Cela signifie que l'accès à une archive exportée d'un client sera fourni en contactant NaviPartner via les canaux de communication habituels, c'est-à-dire le système de cas, l'e-mail de contact.

Le fichier de schéma auquel les archives adhèrent peut être téléchargé sur:
[Schéma d'archive](../files/nf525_schema.xsd)

Vous pouvez toujours exporter manuellement une période mensuelle également en accédant à la page "Récapitulatif des quarts de travail" et en utilisant l'action "Archive".

## Validation des archives

Pour garantir l'intégrité des archives exportées, toutes les archives .xml sont signées à l'aide du même certificat que toutes les signatures d'événements POS.

La méthode de canonisation XMLDSIG est XML-C14N 1.0 et la signature est effectuée via RSA & SHA256 comme toutes les autres signatures d'événements POS.
Si vous contactez NaviPartner, nous pouvons vous fournir un fichier de certificat .cer qui inclut la clé publique du certificat utilisé par un client spécifique.
NaviPartner fournit également un script powershell qui peut être téléchargé et exécuté pour valider à la fois le schéma du fichier XML et la validité de la signature :
[Schéma de validation des archives](../files/nf525_validate_archive.ps1)

Il prend 3 paramètres :
- archivePath: L'archive à valider
- schemaPath: Le fichier de schéma XML pour le valider par rapport
- certificatePath: le fichier de certificat .cer.

Le moyen le plus simple d'exécuter le script est de placer les 4 fichiers, c'est-à-dire l'archive, le schéma, le certificat et le script dans le même dossier - après quoi vous pouvez exécuter le script comme ceci :
![Exécution du script](../images/script_execution.png)

## Structure des archives

L'archive contient la structure globale de :
```
<Archive>
    <GrandPeriod>
        <ArchiveSignature/>
        <SystemEntryNo/>
        <SequentialID/>
        <FromDate/>
        <ToDate/>
        <GrandTotal/>
        <PerpetualAbsoluteGrandTotal/>
        <PerpetualGrandTotal/>
        <PeriodGrandTotalSignature/>

        <Tickets/>        

        <Duplicates/>        

        <GrandTotals/>        

        <JET/>        
    </GrandPeriod>

    <Signature/>    
</Archive>
```
Tout d'abord, une section d'en-tête pour la grande période mensuelle archivée, suivie de listes de tous les événements signés au cours de cette période.
Après l'élément GrandPeriod se trouve un élément Signature qui contient la signature XML du fichier, ce qui le rend inviolable.

Voir le fichier de schéma lié ci-dessus pour un aperçu détaillé de tous les éléments XML dans chacune des 4 sections de type d'événement (tickets, doublons, grands totaux, jet).

## Héritage

Avant la version 11 de NPRetail, les fichiers d'archive n'étaient pas signés et suivaient un schéma différent. L'ancien schéma peut être téléchargé à partir de :
[Ancien schéma d'archivage](../files/nf525_schema_old.xsd)