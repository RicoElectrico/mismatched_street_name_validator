CREATE OR REPLACE FUNCTION canonical_name (name text)
    RETURNS text AS
$$
DECLARE
    stop_words CONSTANT text := '(ulica|generala|ksiedza|ksiezy|ksiecia|ksieznej|ksiazat|krola|'
    'krolowej|biskupa|arcybiskupa|kardynala|doktora|inzyniera|profesora|'
    'marszalka|kapitana|porucznika|podporucznika|pulkownika|podpulkownika|'
    'majora|hetmana|kanclerza|admirala|kontradmirala|wiceadmirala|komandora|'
    'rotmistrza|sierzanta|kapelana|kanonika|ojca|prymasa|pralata|pilota|'
    'plutonowego|pasaz|skwer|sciezka|hrabiego|hrabiny|braci|siostr|'
    'rodziny|van|swietego|swietej|swietych|blogoslawionego|'
    'blogoslawionej|blogoslawionych|abrahama|achacego|adama|adelajdy|adolfa|'
    'adriana|ady|agaty|agnieszki|ahmeda|alberta|albina|aleksandra|aleksandry|'
    'alfreda|alfonsa|alicji|alojzego|amadeusza|ambrozego|anastazego|anatola|'
    'andrzeja|anety|angeli|anieli|anity|anny|antonia|antoniego|antoniny|'
    'apoloniusza|arkadiusza|arkadego|arona|artura|azalii|augusta|aureliusza|'
    'balbiny|baltazara|barbary|barnaby|bartlomieja|bartosza|bazylego|beaty|'
    'benedykta|beniamina|blazeja|bogdana|bogny|bogumila|bogumily|boleslawa|'
    'bonifacego|boryslawa|bozeny|bronislawa|bruno|brunona|brygidy|cecylii|'
    'celiny|cezarego|christiana|cypriana|cyryla|czeslawa|czeslawy|dagmary|'
    'damiana|daniela|danuty|darii|dariusza|dawida|dezyderego|dionizego|'
    'dominika|dominiki|donalda|doroty|dymitra|edmunda|edwarda|edwina|edyty|'
    'elizy|elzbiety|emila|emiliana|emiliusza|emilii|eryka|eugeniusza|'
    'eustachego|euzebii|eweliny|ewy|fabiana|faustyna|feliksa|felicjana|'
    'ferdinanda|ferdynanda|ferreriusza|filipa|fiodora|floriana|francisa|'
    'franciszka|fryderyka|gabriela|gabrieli|gawla|genowefy|geralda|gerwazego|'
    'giuseppe|grazyny|grety|grzegorza|guglielmo|gustawa|haliny|hanki|hanny|'
    'hansa|hektora|heleny|helmuta|henryka|herakliusza|herberta|hermenegildy|'
    'hieronima|hilarego|hipolita|honorata|honoraty|huberta|hugo|hugona|'
    'icchaka|ignacego|igora|ildefonsa|indiry|ireneusza|ireny|iwo|iwony|'
    'izabeli|izydora|jacka|jadwigi|jagny|jagody|jakuba|jana|janiny|janka|'
    'janusza|jaroslawa|jasminy|jawaharlala|jeremiasza|jeremiego|jerzego|'
    'jedrzeja|joachima|johana|johannesa|johna|jonasza|jolanty|jozefa|jozefata|'
    'jozefiny|juliana|julii|juliusza|juranda|jurija|justyny|kacpra|kajetana|'
    'kaji|kamila|kalasantego|karola|karoliny|katarzyny|kazimiery|kazimierza|'
    'kingi|klaudii|klaudiusza|klemensa|klementyny|kleofasa|kolumby|konrada|'
    'konstantego|kornela|krystiana|krystyny|krzysztofa|ksawerego|lajosa|lecha|'
    'lejba|leny|leokadii|leona|leonida|leopolda|leszka|lidii|longina|louisa|'
    'lucjana|lucyny|ludwika|ludwiki|ludomily|ludomila|ludomira|lazarza|lucji|'
    'lukasza|macieja|magdaleny|mahatmy|maji|maksymiliana|malwiny|malgorzaty|'
    'mamerta|marcelego|marceliny|marcina|marii|mariana|marianny|marioli|'
    'mariusza|marleny|marka|marty|martyny|maryli|marzeny|mateusza|matyldy|'
    'maurycego|melanii|melchiora|michaila|michala|michaliny|mieczyslawa|'
    'mieczyslawy|mikolaja|mileny|milosza|mirona|miroslawa|miroslawy|moniki|'
    'mordechaja|natalii|nepomucena|niccolo|nikodema|niny|norberta|ofelii|'
    'olafa|olenki|olgi|olgierda|oliwii|onufrego|oskara|otylii|paavo|pabla|'
    'pablo|pafnucego|pankracego|paschalisa|patrycji|patryka|pauliny|pawla|'
    'piotra|piusa|poli|porfirego|prota|protazego|przemyslawa|rabindrannatha|'
    'radoslawa|rafala|rajmunda|remigiusza|renaty|roberta|rocha|rolanda|romana|'
    'romualda|rosy|rudolfa|ryszarda|sabiny|salvadora|samuela|sandora|sandry|'
    'sary|saszy|saturnina|sebastiana|sergiusza|seweryna|siergieja|slawoja|'
    'slawomira|slawomiry|sobieslawa|stanislawa|stefana|stefanii|sue|sylwestra|'
    'sylwii|szczepana|szymona|tadeusza|tamary|teodora|teofila|teresy|thomasa|'
    'tobiasza|tomasza|tomcia|tymona|tymoteusza|tytusa|urszuli|vincenta|'
    'waclawa|waldemara|walentego|walentyny|walerego|waleriana|walerii|wandy|'
    'wawrzynca|wenantego|weroniki|wespazjana|wieslawa|wieslawy|wiktora|'
    'wiktorii|wilhelma|wincentego|wincentyny|wioletty|wislawy|wita|witolda|'
    'wlastimila|wladyslawa|wlodzimierza|wojciecha|wolfganga|woodrowa|xawerego|'
    'zachariasza|zbigniewa|zbyszka|zdzislawa|zdzislawy|zenobii|zenobiusza|'
    'zenona|zofii|zuzanny|zygfryda|zygfrydy|zygmunta|zanety) ';
BEGIN
    name = lower(unaccent(name));
 -- Uncomment the line below to enable removal of stop words like given names (John) or person titles (Professor, General etc.)
 -- The default list for Polish adapted from https://github.com/balrog-kun/shrtnms/blob/master/shorten.c   
 -- name = regexp_replace(name,stop_words,'','g');
    name = regexp_replace(name,'[^[:alnum:]]','','g');
    RETURN name;
END;
$$
LANGUAGE plpgsql IMMUTABLE;
