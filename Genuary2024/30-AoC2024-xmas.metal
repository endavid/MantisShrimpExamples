// #Genuary30 shaders
// I solved Advent of Code 2024 Day 4 part 2 with a shader... 
// Except you have to get the image out and count the number of non-black pixels
// Each pixel is actually a blinking SDF circle, just for fun
// The color represents the pattern type that matched.
//
// I was curious if strings would compile in a Metal shader and they do.

constant char XMAS_MAP[] =
"MMMMAXASMSXXMMSMXASXMSSMMMAXXMAXAMXSSSMMSMSSSSMMMSXMSSMMSAXMASMMMSAMXSXSMMXMSMMAMAMXXSXSXMAMMMXSSMMSSMMMSSMMSAMXMXMASXMASXXSSMSAMMXMASXMMMXA"
"AAAMAAXMAMMMSAMMXMAXXAAASMSMSSMMXMXXAAAXAAXAAAAXASASAAAAMMSAMXMAXSASXSAAMSAAAAXXASAMXAAMAMASMMASAXMAMAAAAAAXMASXMXMAXAMXMMXAMXMMSSMSAAXMASXM"
"SSXXXAMMAMXAMASMMXSAMMXMMAXAMAMMAXMMMMMSXMMMMMSMASMMSMMMSASASAMXMSAMAMXMASMSSSMMMMAMSMMMASMSAMXXMMMAXMMMSSMMSAMXSAMXSXSAAMMMSAMXAAMMASXAAXAS"
"XMXAXMAMMMMSMSMXAAXAMXSXMMMAMAASASXSMAMXAMSXSAAMXMMAMSMMMMSASXSMMMMMAMXXXXAMAMAMASAMAAAXXSASXMMMSSMXMMAXAAMMMMMMSASASASMXSAMMXSMMSXSAMXMMSMM"
"SAAMAMSXSAMXMMXMMMXAMAAXSXMXMSXMASAASMMMSMMAMSMSMMMXSAXASXMXMMXMXAMSSSMMSMMMAMSMMSASXSMSXMXMMXSAAMMAASMMMSXMAXAXSAMXSXXXAMASAASXMAAMXSXAAAAA"
"XAMXAMXASXSASXMXMMSSMXMMXMASXXXMAMXMMXAAMAMXMAXXXXASXMMMXAMSXSAMMXMAAAAAAXXSSMXAXSXMAAAAXSXMXAMMSMMMXXAAXAMSAMMMMXMAXAMMMSMMMMMAAMAMAXMMXSSM"
"XSXSSSMAMAMASMASXXAMMMSAXMASAMXSAMXMSSMMSSMMMSAMXMSAMAXSSSMAAMAXAAMMSMMASXMXXASMMSAMXMAMSXASMMSAAAXMXMSMMMXMAXSAMAMSSMMAMAMAXMSMMXSMMMMAAMMM"
"AXAMXAMSMSMASASXMMASAAMMMSSMXMAMAMXXAMXXXXMAAXAMAXXMASXMAMXMASMSSXSAMXXAMAMAMMMXASMMXXMMSMMMXAAXXMXSAMAXXSAMAMSAMAMXAMSXSASMSAAXMAMASXMMMXAM"
"AMAMSAMAAXMAMXMMMSXMMASAASXMAMSSMMSMMSSMXMXMMSSSXSAXXMAMAMXXXXAAAXMASMMMMSMSXSMMMMMMMSXAXASAMMSSMSAXAMASAXASMMXMSMXMXMAMMXSASMMSMASAMXXSMSSM"
"MXMMXASMSMMSSSXMMMXMASMMSMAMMSAAMAMAAAAXAAAMXMAAAXAMXMXMXXMSAMXMXMMAMXAAAXMMASMSXAXAAXMMSXMASAAXAMMSMMMSASXMMSAMAMXXSSSSSSMMMAAAMXMMXXSAMAAM"
"SASMMMMAXMAMAMMXAMAMXMXMAXAMXMXSMAXSMSSMMXMSAMMMMMSMSMASXSSMSXXXXSMSSSSMMMAMAMASAMXMSSXXAMSAMMSMSAXAXSAMAMAAXXAXAMMMMAAAMMAMSMMSAMMMSMMAMSSM"
"SXSAASMXMMXSAMASMSMMMSAMMXMXSMAMMSXXAMXXSAXSMMAAAXMAAASMMSAAXXSAMXAAAXXAXSAMXMAMASXMAAMSAXMXSAMXXMMMSMAMMMSMMSSMMSAAMMMMMXAMAAXXXAAAAMSAMXAA"
"SAMMMSAMXAXMAAMAXAAAASMSSSMSMMASAMXMAMMAMXMMMSMSSXMXMXMAXSMMMMSAXMMMMMSXMAMXXMASAMAMMMMMSMXMAXMSMAAMAMXMAMXMAAMASAMSSXSASAASMSMSMMMSXMAMSSXM"
"MXMASXMAMASXSMMMSSMMMSXAAAXAASXSAMASAMXXXAMAAAXAXASXXXSXMSAXSASMMXSMSASMMSAMXXAMASXMXSAAXXSMASXSASXSMSMSXSAXXMXMMMXMAXSAMXMMMAAAAAMMMXSAXXAS"
"SAMXSAAMSMMXAAXXMXXSASMMSMMSAMXMASASMXXMSXSASMMMMAMAMMMMXSXAMXSMSAMAMASAAXAXMMSSMMAAXXMMXAXMXSAXAMASAAAMMSASAXAXMXMMMAMAMXSASMSMSMSAAAXSMMSS"
"XMAMSXMXSAMSSMMSMMXMAMXXMMMXMXASXMASXSAMSAXAMXMSASMSMAAMXMMXMSXMMAMMMMMMMMSAAAXAMSMMXMSMMMMMMMMMAMXMXMSMAMAMXSSSMAAAAXMSMAAAMAXAAAAMMXSASMAS"
"MASAMMMAMAMAASAAAXAMMMMXMAMSMMAXAMAXAXSMMMMXMMXXAMAASXSMAXAAMXAMSSMXSXMMMAMMMMSAMXSSMMSAMMAXXAASAMAXAXAMXSAAMXMAXMSMXMMMXMMAMXMMMSMMMXSAMMXM"
"AAMMAAMXXAMMSMSSSSXSAASMSSSMSAASXSMMSSXXAMAMMMMMXMXMXMAXXMXXSSXMAXAAXASMMSSSSXXXXAMSAMSAMSSMMSMSMSASMSAMXSMSMASMAXAASMSSMXMSSXMSAXAMXAMAMXSS"
"MAMXXSXMSMMXAXXXAMXMXMMAAMMAMMXMAAXAXAMSMSSXAAAMXSXMSSSMMMSAXAMMMSXMSMMAAMAAMMMMMASXXMMSMAAAXMMXXMASMAMXMXMAMXSASMMXSAAXMAMAMAMMMMMMMXSAMAMA"
"SSSSMAMMASXSSSXMXMASXSMMMMMAMXSMSMMSSMMXXAMXSSSMAMAXAAAAAAMXXAXXASAMXASMMMMMMAMAMMXXAMMASMSMMMMMAMSMMASMXMSASMSAXAMAMMMMMSMMSAMASXXAAXMAXSSS"
"SXAAMAMXASXAXAXMMSMSAAAXXMSXSAMXMXMXSXASMXSAXXAMAMAMMMMMSXMAXXMXXXAMSMMMMXSASXSASXAMXMXAMMMAAAAMXMXXMASAAXMASAMAMXMASXSAAAAASASAXMXMSMSMMMAX"
"MMSMMASMAMMSMMXXAMAMXMMMSAAAXMXAMXXAXMMAAAMASXMMSSXXMASXXAMMXSASMSMMMAAMSASASXSASMMXAXMAXAXSSSMSAMMXMASMXMMMMXMMMMMMMAMXXMXXMAMMSMSAAMAMXMAM"
"SAMXSASMAMAXAXMMSSMXASAXXMASXMSXXMMSSSXMMMSXSAMAMMXSSMSAMMMXXAASAAAASMMMMASXMASAMXXAXMSMSMMAXAMSXXAAMAXXMXSMSASAAXSSMMMXXSSSMXMXAAMSMSMSMMSM"
"SASAMMSXSMMSMAMAAAXSAMXSAXAXMAAXMMXMAXXXMXMMMAMSSMAXAAMMMASMMMXMMSSMSAAXMAMXMAMMMXXMSAXAAXMXMSMMAXSXMASMXAXASASMSMAXAXSXXMAXASMMMAMMXMXXXMAM"
"SAMMSAMXMAAXXAMXSSMMAMSMMMMSMSASMAXMMMMMSASAMSMXAMXSMMMASMSAMMMSMMMAMMMMAXMAMAMAMMXMAMMMMMSAMAAMMMAAMMAMMMMMMXMAXAMMSAMXMMAMXXXMSASXAMSSMMSX"
"MXMASMMMSSMSMXXMAMXMMMAAAASXAMSAMXSMASXAXMXMSAMSXMMMASXXSMMAMXAMAAMXMSMXMAXXMSXMAXAMSSMXAAMMMMMMAAMXXMASAMAXSAMMMXXXMXMAXMASXAMXSASXXXAAAAXS"
"XAMXSSXAAAXSMSMSAXSSSSSMMMAMXMAXMXSXAMMMSSSSSMXMAMASAMSSMXSMMMSSSMMAMAAASMMSMMASASMXAAMMMSXXASMSXSXMXSMMMSSSSMSMXSSSMMSMXSASMAMAMAMMSMSSMMMS"
"SSSMXXMMSXMSMMAMMMMAAAMXSXMMSMXMSAMMMSSMAXXXMXXSAMMMMSMSAAXAAMAMXMSASMXMXAMAASAMXAXSMSMSAMAMAAAAAXAMXMXXXAMXMXAXMXAASAAAMMMSXAMASXMAAXAXMSAS"
"XXAMAXMAMMMSSMXMMAMMMMMASAXAAMAAMASXXAXMMMMMMAMSASXSMAAMMMSMMSMMAMMMSASXSSSMMMXMXMASAAAMASXMMMMSMMAXXMAXMAMSMMMXAMMMASMSMAASMMXXSAMMSSMMAMAS"
"AXAMMSMAXSAMXXMXSXSAMXMAMXMSSSMSSXMXMASMMAAAMAMMXMASXMMMAXAMXAXMASXXMXMAAAXXXXXXASAMAMMMAMMMXXAAXXXMAMSSSXMASXMASXSMAXMXXSSMSMASMXSSXXAMMMAM"
"XSAAXXMAMMMXSAMXSXXMMAMXXSAAXXMMAMXXMASASXSMSXSXSMXMASMSSSMAMSMSAXAASMMMMMSXSAXSXMASXMSMSXXXAMSXSASMMMXAAXSAMXXXAAAMAMXAMMAAXMXSAAXMMXXMXMAX"
"MAMAMSMSSSXAXMMAMAAXSXSXAXMXMSAAMAXMMASAMAMXSAMAXMMAMSAAAMXSXMASASMMMASXSAAAXXMSMSAMAXMAXASMXMAXMAAAAXMMMMSASAMXMSMMAMMSXSMMMMMMMMSAMMAMSSSS"
"XMMMMAAAMAMASXMASMMMMASMMXSXAXMMXXMAMAMMMSMAMAMSSMMAMMMMSMAMAMMMAAXAXSAAMMMSXMASAMASAMAMSMSAMXMXMASAMMMMAXSAMXMSXAXXASMXXSMMASAAAXSAASXMXAMX"
"MXAAXMMMSMMAAXSAMMAAMMMASASMSXSXAXSASXSXAMMSSXAAAASXXSAMAMASXSXMSMSXMXMXMXAMXMASXMMMMSAXMASMMAMSXMAMXAXMAMMSMSAMXSXSASASAMASASMSMXMMMMAMMAMX"
"XMXMXAXAMXMXSMMASXSSSXSAMMXAMASMSXSAMAAMASAAAMMSXMMAXSASXSASAAAMMAMXAMXASXAMXMASAMXAASXSMAMMMAXAAMAXSSMMMMMAXAMAXAXMMMMMASMMASAMMXAAXSAMXAMX"
"XSAMSMMXMAMMMASXMAAAAAMXSXMXMXMAXAMXMSMSXMMSMMAMAMMXMSAMXMAMXMASAAMSXMMAXMAXAMAMMMSMMSASMMMSSMSSMMMAXMASAXXSXMMSXMASXMXSAMXMAMAMXXMMXMAXSASA"
"SMMXASXXXAMASXMSMMMMMMMXMAMAMAMSMXMSXMASXMAXXMASMMMMMXMMXSMSSXXXMMMXMSSMMSSSMSMSMAMXXMAMAXAAXXXAAAMXMSAMASMXAXAMASAMXSAMXSMMXSXMSSMSSXMMSSMX"
"AAMSAMXAASXMXASXXXXMASXXMASMSSMMXAXXAMAMAMASAMASAAAMXAXSXMAAMMMMSMMAAAAAAAAAMXMAMXSMXMASXMMASXMMSXSMXMASAXASMMSXAMASAMXSAMASAMMAAAMSAASAMASM"
"MSMMAMMMMMASXMASMSXMSSXSMXXMAMAMMMMSXMAXXMXSXMASMSMSSMMSAMMMXSAAAASAMSSMMSSSMMSSSMAMXSASXXXAMAMAAAAXXSXMXXXAMAXMASXMMSSMMSAMASXMSSMMXMMAXMMM"
"XMAXAXASXMAMXXMASAAMAMMXXMASASXMAXAMASASMMASXMXMMXMAAXAXAMXSASXSMMMXMAXMXAXAAAAAAMAMXMXMXMMXSAMASXMMMMMAXXMXMASMAXXAXMMAAMXSAMAMXMMMXSSSMSAM"
"SSSSSSSSXMSSMAXXASXMASXSXMASAMASXSMSMMSAAMAMAMXMSMMSSMMSMSAMXMMMXMMAAMMSMSSSMMSSMMMSSMSMSAAASXSXXXXXXAMMMMAAMXXMAMSMMSMXMXAMASXMSAAMMMAMASAS"
"MAMAAXAXMMAAXXMMMMXSXXAMAMAMAMAMASAAAXMXSXMXAMAMAAMMAMXAMMXMAAAAAMSSMSAMXXAAXAXXMXAAMAAAMMXAMXMASMMSSMSAAXMSSMSMMMSAAMMMSMASXMXAMSMSAMAMASXM"
"MAMMMSMMAMSSMSASXMASAMXXAMAXMMASAMMMSXMAMXMSSSXMMMMSSSMMSMMSSSMMXXAAAMAMSMMMMXXAMAMXMMMSMSMXSAMAMAAAAXSMXSAAAASXXAMMMSAAAXXMASMSMXXSXSMSXXAX"
"SASAAAAMXMAAAXMAAMASXXASXSMSXXXMAMSMXAMASAXAAXMMSAAXXXXXMAAAMAXAXMMMMXAMAAXSXSSSMAMXXSXAAAAASAMMSMMSSMSAAXMMMMMAMSSMASMSXMXMXMAAASXMASAMMMSM"
"SXSMSXXMSSSMAXXXXMXMXAAXMAAAAMMMSMAAXXXASAMMSMMAMASXXAMMSMMXSAMSMXSAMSSMMSMMAXAMXSMMMASMSSMMSAMAMAMMMAMMMXXAXAMXMAAMASAXXMAXMMSMSAXMAMAMMAXA"
"SAMAXAMXAXAAAMAMXMXXSMSXSMMMASAAXSMMMMAAXAMXAMMMSMMMMSSMAMSMMXSXAAMAMAAMXMAMMMSMAXAMSAXMAMXXSAMAXXXAMSMMMSMXXMSMMSSMAMMMAMAXSAMXMMMMAMXMMMMA"
"MAMAMMAMMSMMMAAAMSMMMAAAMXMSAXMMXAXMAMAMMAMSXSAMAAAMXAMMAMXAAMMMMMXSMSSMASASXMAMASAMMXMMASAMXMSMSSMAMXAXXAMSSMMXAMXMASXSXMAXMAMAMXMMMXMSSSSX"
"XAMASMSAAXAAXXMXMASXMAMXMAAMAXMXSMMSMSASXMMMMSASMSMSXMXSMSSMMMAMMSAMXAAMASMMASXMASMMMSXSASASAMSAAXSAMMMMMASMAAMMMSASXMASMMSXSAMXMAMXSAAAAAMX"
"SAXMMXMMXSSMSSMASASXSMSMSMSXSMSASMAXAMASAMAAASMMMMAXMXAMXXMMASASAMASXMMMAMAXXMAMAXAAAXMMXSAMXAMMMMXMXXSASMXMSMMSASXMMMMMAAMASMMSSMSAXMSMMXMM"
"AMSSMMSMAMMMAASXMASAXAAMXSXXAAMASMMMXMXMMSSSXXXSAMXMAMSSSMXSASMSASXMMASMASXMSSSMSSSMSSXSAMXMMXMAASXSMXSAXXMAMXAAMSMSASAAMMSXMAAXAMMXXAXXXAXA"
"MXAAAASAMXAXSMMMSAMXMSMSXMMMMXMSMMXAMMSXXAAMXMSXMMSAMSMAXAAMAXXMXMMMXMMAAAXAXAAAMAMXMAMXSASXSASXXSAAAAMAMSASXMASXSASASXSAXXASXMSAMXMASMMSMMS"
"XMSSMMSAMSMXMXSXMSMXXMMSAMXXMMMXAMXSXAAMMMSMXSAMSASXXMMSMMMSAMSSSSXMAXXXMMMSMSMMMSMMXMASAXMAXASXAMMMSXMAMXAXMASMXMAMAMAMXAMXMAMXMSXSAMAAAMSM"
"XAAAXXXXMAXAAAMAAMXXAMASAXXXMASMAMSAMXSMXXMASMXMMASAMXAMAAXMASXAAAASXSMSAXAAAAAAXMAMSXMSMMMMMXMMMXXXAXMASMAMSSXMAMSMSMAXAXMASXXAMXAMXSSSMSAX"
"MSSMMSMMXSSSMMMMXSASMMASAMMXXMXMMXMASAXXSXMSMMASMAMMAMASXMMSXMMMMMAMAAASXMSSMSSMSMSMSAMXXAAXMMMAXXSXMXXAXXMMMMMSMMAAXMASMSSMMMSMMMSMAXMAXSAS"
"AAAXASAMAMXMAAXSMXMSAMXSMMASMMMASMSAMXSXSAXMASXSMAMXASMXMAMMAXAMMMSMMMMMAMAXMAXAXAAXMAMSSMSMSAXSMXASXXMMMXMXXAMMMMMSMSXXXAAAXAAAXAMXXMMMMSAA"
"XSAMMSAMSXASMMMSMAXSAMMSAMSAAASAMAMXXAMMMMMXMMAXXMSMAAMAMMASASXSXAAAAMXMMMAMMAMMMSMSSSMMAAAAXSMAAXMASMAMAMXAMXSAASXXAMXMMSSMMSMSMAXMMXSXMMSM"
"XMAAASXMMMMMAAXXSXXSXMASAMXMSMMASXSMSMSSSMAASMSMXXAXMAXAMXAXAMMMMXSMMXSXMMSSMXSXAAAAXMASMMMSMXSSSSXMXSAXSXSMSMSMSSMMXMAMAMMMMXAXXSMXAAAAXAMS"
"XSAMMSXMXAMSSSMMAMASXSXMAMXXMXSMSAXAAAAXMMSXSAAAMSSSMMXSAMSMMMAAAXMAMASAMAMAXMMMSSMSSSMMMSXMAMAMXMAMXMMXXASAAXMXXMAMAXAMXXAAMXMSAMAXSMSSMMSX"
"MXSXAMASMMMAAXXMASMSXMASAMMXMAXAMAMSMMMSXAXAMXMMMAMMMAAMMXMASXSMSAXAMASAMXSSMSAMXXXMXXXAMAAMMMMMMSMMMAMAMMMSMSSMSXSXSSSSMSSXSAXMAMSMMAAXAXXM"
"MAMMASXMAXMMMMMSAMXMAMAMAASXMAMMMXAMXSAAMXXAAASMMMSAMMSSXAXAMAXXAMSMMXSMMXXMASMSASMMMXSASMSMXMAAAAXAXAMXSXAXMAMASAMAXAXAMAXMSMSMSMXAXMMMSMAA"
"MASXMXMMSMMXSAXMAXSASXAMXMAAAMSXAMXXAMASMMSSSMSAAXMASAAMXMMMSXMXMXMXAXMAXXAMXMAMASAAMAXMXXXMASMMSSMXXAMXSMMSMAMMMAMAMMMSMAXXMAXAAAMXMASAMMSM"
"SXMAXXSAXAXASASXSMMAMSMMXMASMXMASMMMXMAMAAAAAASMMMSAMMXSAMXXAXAXXAAMMSXMSMMMXMXMSMMAMAXSAMXXAXAXXAAXSSMXMAMXMSSSSSMXMSAXMMSAMAMSMSMXSAXXXAAX"
"SASMMMMMMMMMSAMXAAMAMAXSXMXXAXXAAAAAMMSSXMMSMMMMSXMASXXSMXSASMSMSSSSMAMAXAASXMXMMMMXMAXMAXASMSMMSMSMAAXXSSMXAXAAAAMAAMMMASAMXAAAAXAXMASAMSSS"
"MAMMASAMASAMMAMSSMMSSXMMMMMAXXMMSMMXXXAAASMXAAXAMMSMMMXMAMAMXAXAAAXMXAMMSSMSAMAMSSSSSSSSXMXMAAMAAAAMXMMMMASMSMMMMMMMSAMXMMAXSXSMSMSMXAAXXAMX"
"MXMXXMXSASASMMMAAXAXXMSMAXAMMSAMAMSSSMMSMMMMSMMMSAMAAXAMAMMXMSMMMSMMSXSAAMAXMXASXAAAAAMXMMSMSMMSMSMMAXAASMXXXAMMXMXMXMAMSSSMMAMAMAASMSSSMMSS"
"MSSMMAXMASXMAMMSMMMMXAAMSSMSMXMXAMAAAAAAMXXAAASAMASMMSMSXSXMAXSSXMAXXAMMXSMMMSMSMMMMMMMASXAAAAXMAMMXSMXMSXMMXAMMASAMSMSMAXXAMXMAMSMXMAAXAAAX"
"SMAAMXXMAMMSAMMXXAAXMMSXMAAAMXSSSSMSMMMSSXMXSSMAMAXAMXASXMXSSMAXAMSMMMMMXSAMXAAXMXSMAXSAMMMSSSMAAXMAMASMMMAAMSMSASASAAAMMMMSMXSAXAMXMMSMSMMS"
"SSSXMMMMMXAMASAMSSMSMAXASMSMSAMMMAMXMAMXXMMAXXXMMSSMMASXXXAMXMMMXMXASXXMASAASMSMSMASMMMXSAXAAAAMSSMMSMMAASXSXXAMAMXMMSMSSMAXSMMXSMXXMSMAMAAA"
"MAMXAMSASMSMXMAXXXAAMMSAMAMXMASXMSMASASXAAMXSAAMAMXMASAXMMXSAASAMXSAMAAMASXMAAAAMXAMXAAASMMMSMMMXAMXAAXMXMAMAMXMMXSSXAASAMXMAMSASMSXMAXAMMMS"
"MAMMXMSASAMXSSXMAMSMSXMAMAMMSXMMSAMASMSMMSAMMMMMASAMXXMAMAASXMXSAXMMMSSMXMAAMSMSXMMSXMMMSASXAXXXMAXSSSMMAMXMAMXMMAMASMXSXSMSAMXAMAAXXASMXSAA"
"MXSMAXMAMAMAMAMAXAAAAAXXMAMXSAAXXMMXSASMAMAMSAXSASASAXMAMAXXMMMXMMAXAAAMMSSMXXXAXSXSMMAASMMSXMXMSSMAAMMSASAMAMSXMASMXSAMAXAMXSMMMMMSMASMAMXS"
"XXAXXMMXSXMMSAASXSMSMXXASXSASMMMSXMXMAMMXSXMSAXMASAMAXSASMMXAASMSSSMMXSMMAAXAXMSMMASXMMXSAMMSMAXAXMMMMMSSSXSAMXASXSXAMMMSMXMAMAMXXAAMMMMAMAA"
"MSAMMXSXXXAMMMMMAAAMAMSMMMMXSXAAXXXAMSMXMXMXMSMMAMAMAMMXXAASMMSAAXAAAMXXMSSMSSMAAMAMAMMXSAMAAMMSAXSXXMASAMXSXSAMXMMMSMMXXAAMSSSMASMXSAAMASXS"
"XAAXMASAMSMMAMMMSMMMAMSAAXMAMXMSMMMSSMMMMSXXAAXMXSAMXSAMMMMMSAMMMSSMMSMAXXXAXAMSXMASAMAASMMSSSXAMMSXMMXXAMMMAXAMAMXAMAMAXSAMXAAMAXMASMMSASAM"
"MXAMXAMAMMASASAAMMXSXASXMXXMSSMXXAAXXMXAMMMMSMSXASASASXMAXXAMXMAMMAMMAMMMSXMXMMMMSMSMMMAMXXXAMMSMAXASXMSSSMMMMMSASAMXAMXMMASMSMMXSXMXAMXAMXM"
"ASXAMMMAMXMMAXMXSMMMMXMAMSMXMAAXMMMSAMSXXAAMAMXMASAMXSAASMMSMMSSXMAXSXMASASMXSAMXSXMASAMXSSMSMAAMXSMMAXAAAMXMAMSMSASMMXSMSXMAXAXAAAXSSMSSMMM"
"XAMMSXSASAAMMMSSXXAXSSMAMAAASMMMMXMSAMAXSSXSAXAMXSXMMXMMMAAMAXAMMSSMSASMSAMXAMASMMSMAMASAMAAXMSSSXMASXMMSMMMMMXXAMAMXAASASXMASAMXSSMMAAAXAAM"
"AMSAAAAAMMSMMAMAMSXMSASMSMSMSXMAXMAMAMMXAMASAMSMMMASXMSAXMSSXMASAXAASAMXMMMMXMAXAMXMASAMASMMMMXMAMSAMAXXXAXSASMSXMMMMMMSAMAMXMXMXXMASMMMSXMX"
"MXMMSSMSMMMXMASAXSMMSAMXAAMASXMMMSASMMXMASXXMAMAASAMXXSASXMAXXAMMAMMMAMASXSXSMMSAMXSASAXXMAAXAAXSAMASMMSSMMSAMAMMXMASMXMAMXMASAMXASAMASASMSX"
"XAXAXAAAAAMMSMXMMXAXMASMMSMAMXSAASASXSAMMMMMXSMSMSMMMMMMMAAMMMSSMXXSXSSXSAMAMAMAXMMMXMASXXMMMMXXMAMASXSAMXASMMSMMASASXMMAMXSXSASMAMMSXMASASM"
"SMSMMMSMSMMMASXMMSAMXSMXXMMAMAAMMMAMASASAMAMAXAMXXAAXAAAXXMXAXMAMXAAAASMMMMAMAMSSSXSXMAXMASMSMSXSAMAXXXXAXASAAXAMXSAMAMSMSAXAMXMXAXMAMMXMMMX"
"XMAAAAAXXMXSAMMAAMAMXXAMXMXSMXSSSMSMXMAMMMSXMMMXASMMSSSMSAASMSSXMSAMXMMXAMXXSXXMAXASMMMSMSMAAASASXMMSMMXMMASMMSSMMSAMAMAXXMMSMMMMMXMMAMASXMA"
"SXMMMSSSSSXMMMSMMSSSMMAAASAMXMMAMAAAXMXMSAMASAXMMMSAAAAASMMAAMXXAXMXSSSMSSMXAMXMAMXMAAXMXMMSSMMAMXSAAAAMXSMMXMAXMASASXSXSSXMMSXAASXSMASASASX"
"XAXSAXMMXMAAXAAAAAAAXSMSXMASMMMAMSMSMASXMASAMMASAAMMMSMXMASXMASMMMSAMXAAAAXMMAAMAMSSSMMSAMMXMAMXMASXSMMAMMAMSMMMMMMAMMSAXMASAMMMMSAASXMASAMA"
"SSMAXSMSASMMMSSSMMMMMAAMMSSSMSSXXXMAAMMASXMMXXXSMSSMAAXASAMAMXXAMAMAMSSMMSMMSSSXXSAAASXSAXXAMAMAMXSAMAXSMSAMSAMSMXMXMASMMSAMXSAAXMXMMMMXMMMM"
"XAMMXMAMXXXXXMAMMXMSXXMSAXAXAAAMSAXXXAMAMXAXMMMSMAAMSSSMMSSXMMSAXSSSMXXAMXMAAMAXSXMMMMMSAMMMSASXSAMMMXMXAMMMSXMAAASMMASAAXSMXSMSMSAXAAMXSXAA"
"MSXXAMAMSSXSAMXMMSAMAMXMXMXMMMSAMAMSSMXSAXSMMAAMMMSXXAAXAMMASAAXXXAAMSMSMAMMXMAXMAMMMSXMXSAASASAMXSXMMAMSMSASMSMSMMAMXSMMSMMAMAXXSMSXSMAMSMS"
"MAMXSMXSAAXXAAXXAMXXAMAMSMSMMMMMMMMXAAAAXMXAXMMMSXMMMSSMXSAMXSMSMMSMMSAMMSMSMMXXMAMAXMASAAMXMAMXMAMASXAAAAMMXAAAAXMSAMXXMMMMASXMASXSAMMAMXMX"
"SMMAMXXMMXMSMSSMXSXMASASMASAAAAAMASMMMMSXMSAMASAMMXAAXAAAXMSXXXAXAAXXMAMAAASASXSSMSMMXAMMSXXMMMAMMSAMSMSMSMXMSMMMXXXAMASXMAXXMAMMXMMAMSXSSMS"
"AXMASMSMSXAMSAXXMAMXXMXXMMMSSSSMMMMASXMXAMASMAMASASMSSMMMSSMAMSMASMSMMSMMMSMAMAMSASASMSSMAXXAASXXMMAMAMMMMMSAAASXSMSSMASXMSMMXSMMASXSMMXAAAM"
"MXMXXAAAAMMMMMSSMAMXSMMXSAAXXMAXMXSASAMXAAAXMSSMMXAAMAAMAXAMXMAMAAXAXAAXSSXXMMAMMMMAMAMAMAMXXMMSMSSMSMMSAMAMSMXMAAAAXMAMXXXAAAMASASMAAMSSMMM"
"XSXXMSMSXMAAAXAAMAMAAAMASMSSXMAMSAMASXMXMMMSAAXMSAMMSSMMSSSSMSXSSMSAMXSAMXXMMSXSXMMSMXSAMASXMSAAMAAXXMASAMXMASMMMMMMMMASMASAMXSAMASMMMMAAMMS"
"SAMXMXAMASXSSMSASASXMMMASMMMXMASMAMAMAMAASXMAMASAMXAAAAXMAAAXAMXAMSAMXXAXXXAXAAXAXAMXASMXMMAAXSXSSXMXSASMMXXAMXXSSMXXSMXAXSAXAMMMAMXXAMSXMAA"
"XMSAAMAMAMMAXAMXMAXXAAMXMAAAAMXXXXMASASMSMAMXMSAMXMMSSMMMMMSMXXXAMMSAASMMAMSMXSXMMSSMXSAXSMMMMXMAXAXMAXMASAMXMMAAAXMASASMXSAMSXMMSMXSXMXSMXS"
"XXMMXXAMAXXSASAXMAMSSMSSSXMSSSSMMXSXMASXAMMMAMXMXAXXAAXMAMAAXXMXAMXXMXMXAAMAMAXAMAMAMAMXASASXMASMSSMAMASXMSSXASASMMMAMAMSAMXMMAMAMMAAXAXXXAM"
"MMSMMSSSSSMXAXMMSAMXAAXAAMXAMMMAAMMSMMMMMSMMXXMASXSXSXMXAMSSSXSASASMSMXMSMSAMXSXMXSMMXSAMSAMASAMXAAXSXAMAAAXMAMAAMASAMMMMXMAXSAMASMXMMMXAMAS"
"AAAAXAMXAAMMMMMAXAXSXMMMMXMAMAMMMMAMXASXXAASMAMAXMAMXAAMXMAAXXAAXAMAAAXMAAMMSXMMMMMMAAXMXMXMMMSMMSMMXMASASMSMSMMMSXSXSAAAXXXXSAMASXXXAMSSMSA"
"MSSXMASMSMMMSAXXMSMSSSXXXXSXMXSXXMAMXAMXSSSMMAMMSSMMSMMMSMXSXMMMMAMSMSMSASMXMAMAAAAMMMSXMXSXMAMXXAXMMSAMXXAAMAAXXMAXASXSSMMMMMMSAMMMSXMAXMXM"
"XAAAXAMXMASAMSMSSMAMAXXMMMAASAMXMSMSASMMAXMAXXSAAAAAXMAXAAAXMSAXXXXMMXAMAMMXMMSSSSMXAAXAXAAAMSMMXSAXAMASMMSMSSSMMMMMMMXMAASAAAXMASAAAMMSSMAX"
"XMMSMASXSAMXSAMMAMXMMMXAAMAAMASAAMAMAXMAXMSSMMMMSSMMSSSSMSMXAXASXSAAMMSMXSXMXXAXMMXSASMMMXSMMAAXAXXMXSAMAXMAMAAAAAXMXMMMXMMMXSSSMMMMSSMXAMXS"
"AXAAMXMAMXSMMAXSAMXMXMMSXSAXSMMMXSAMXMMSXMAMAAAMAMXAMAMXXAMMSMXMASMMXMXSAMAMSMAMSAAMXXAMAMXAXSXMMMSAMMAXSAMXMMMSSMMMASASASXXXAMMAMMMXXXXXASX"
"SMSSSXXMMAXASAMSAMXXAXMAXXMASXSAASMMXAMMAMXSSMSMSSMXMAMXSXSAASXMXMXXSXAMXXAMSAAAMMSSMSMMSSSSMXAASAMMXMAMMASAXMAXXAASASASASAXSASXXMAMSMXMXMAX"
"XAMXMMXAMMSXMXXMXMSSMSAMMXMXMAMMMMAXXXAMMMMXAXXAXAAXSMSMSAXXXXMASXMASMMMSSMMSMMSMAAMMXAXMAAXASXMMASASMSMSAMMSMSSMXXMAMAMAMAMSAMAMMAXAAASAXMS"
"XMSAAASXSAAMXMXSASAAXXAMAMSAMAMXSSMMMMSXMSMSSMMMSMMMSSMAMMMSMXMASAMAXAMAMAMASXMAMMMSASMMSMMMXSMASAMXMAMXMAXXSXMAAMSMSMSMSMSMMXMASXMMMXMSAMXX"
"SSXMSXMAXXAMXAMAXAMXMXMMSASXSMSAAASXAAXAXAMAAMMAAAAAXAMMMXAAAXMAXXMMSSMXMXMAXASMSAMMMMAASXAXXMXAMASXMAMMXSMXMASAMXSAAAAAAAXAMXMAXXMASXMXXMXX"
"MASAMAMXMASXSSMSMMMSASXXMAMAXXMASAMXMMXMMMMMSMMXSSMSSMMASMSSSMMSXMXMXMASMXMMSMMSSMMAMXMMMMXXAMMXSMMMSSXSAXAASAMXMXMSMSMSMMMAXXMXSASMSAXAXMXM"
"MXAMSXMXXAXXMASXAXAAAAMXMAMXMXMXMMSMMMXAAXXAMASXAXAMAMSMSAMXXMAXMSAMAXMASAAXXAMXSAXXXASMSMSSMXXAXXAXXMAMASMMSAMMXMAMXMXXAMXAXMAMSAMAMMMSXSAA"
"SMMXAXMMMASASMMSSMXSMMAXSSMMMSMXMAXMAAXSMSMXMAMMMMMSAMXAMAMXXMAMAMAMAXMAMXSMSMMASMMSXMSAAAAXMASMMSMSMMAMXMAXMAMXAXMSAMASAMSXMXSMXSMAMXXMAMSX"
"AAXSMAMASMMXMAMAMAMMMXXAMAMSAAMSMSSMMSMMASASMSMMAAXSMSMSMXMAMMSMSSSMAMMASAXAAAMMXXXMASMXMMMXSMAAAAAAAXXXAMXMXSAXAXAMXMASXMAAXAXMAXMXSXAMSMXM"
"MSAXMAMXMMMMMMMXMAXAXMAXSAMMMMSAAMAXAXAXAMSASAAXMSMMXSAAXXXSAXXXAAAMAMSAMXSXSMMAMMASXMAAMASAMXSMSSSSMMSMSMAMXMAMSMSXSAAXMXXSMSAMSSMXMASAMASM"
"XMASXSSSMSXSASASMXSMMMAAMMSAMMSMSMMMASXMMXXXSMSMMAASAMMMMSAMAMSMMMMMSXXASASMAXMASXAXXMSMSAMASAXMXMXMXAXAAAMMAMAMXAAAXMAXXSAXAMXAAAMASAMAMAMX"
"XMSXAXXMAAAXAMAMSASAAMXXMXSASAMXXAXXXAMXSAMXXMXAMSSMASXSAAAMAASXSASMMMSAMAXMAMSAMXAMMMAMMXSSMMXSXMASMSMSMSASASXMMMMSMXSAAMMMXMMMSMMMAASXMXSX"
"XSMMXMAMMMSMMMMMMSMMMSAASAXASASASAMXXAAAXASAXSXSMXXXXMASAMXSXXSAMASAAMMXMXMMXXAMXXXAXSASAXMAMSAXAMXSAAMAAMAXMMMMXXXXAAMMSMXAXXXMAMSXMAMAMAMX"
"XXXAAMXAAAMXXMAXMMSXAMXMMASXSAMMSASMSMMMSXMMSMAMXMASXMXMAXAAXSMAMASMMSAMMMSAMXSMSSSMXSMMMSSSMMXSAMMMMMSMSMMMMAAAMMSMMSSXMAMXMSXSXXXAMASASAAS"
"MSMSXSAMXMMMMMSMAAXMAMAMSXMXMAMASAMXXAAMSAMXAMMMAMSMMAAMXMSMMXXXMAMAXMASAAMXMSAAAMMMXMSAAXAMXAASMMXAAXAMXAAAXSMMAAXAMAMXMMXMASAMASMXMAMASASA"
"SAAXMMXXAAAMAAXSMMMXAMMMMASXSAMXMSMSSSSSSMMSMSXSSXAXMXMSXAXXAMMMMXSXMSAMMSMAMAMMMSAMXASMXSSXMMXXSMMMSSMSSSMSXXAXSAASAMXSMSMMAMAMAMAAMMSAMXMM"
"MMSMAAMSMSSSMSXSXMASXSMMSAMASAMMMAXMAAXAMXAAMAMMMMMXMAAXMXMXXXMAAAAXMMSMAXMXSAXMMXXMXXMMMSXXXXAAMXSAMAAXAMSMXSAMAMAMAMAMMAAMMSMMMSSXMMAMSSMX"
"MXXXMMXAAXAXAXASXXXAXAAMASMMMMMSSMMSMMMMSMMASASAXXMAXSMMMSMSMMSMMSAMXAMXAXAASXXSASMSMXAXXMAMXMMSMAMASMMMMXAMMMXMMASMMMAMXSSMXAAXAAXAMXASAAMS"
"XSAMSMMMSMAMXMAMMMMSMSMMAMXSAMMAAXMASXXMXAMXSMSASAMMMXAAAXAAXAAXMAMSMSSXSMMMSMMMMSAAMSSMSXXMAAAMMSSMMAAMXMMSSMAAXXMAXMAMMAMMSMXMMXMXSSMMMSMS"
"MMAXAAMAXMMMXMSMAAAXAMXMXMAMASMSSMSMSMXSMMMAXAXXXXSXAMSMSMXMSSXSASMMAAMAXMSAXAASXMMMMXMAMMAXXSAXAXAASXMMAMXAAMXSXMXSMMAXMAMXXSAAXASMMAAAAXMX"
"XSMMSSMAXXASMMXSSSSMAMSSSMXMSMMXAAMXMMMSXAMAMMMMSXMMSMXAMAAMAMXSMMSMMAMMAMMMMSMXAXXMSAMAMMMXAMXMMSAMXSXMASMSSMXXAXAMXMAMMAMMASMMMMAASXMMSXSX"
"XMSMAAMMMSMSAAMAXXXXXXAXMXSXMASXMMMAAAASXSMSMAAXMASAMXMXMSMMAMMXAAXXSXAMSSSMXMSSMMSMSXXMSAMXSAAAMMAASAMSAMXAXMASXMAXAXSMSMSXAXMASXSXMASXMASA"
"MAAXMMASMMMSMMSMSMMXMMMSMAMASMXMASMXXMXSAMAMSXMMSAMXSMMSAMMSSMSSMMSXASXXXAAXXMASMAMAMAMSMXSAMXXXASXMAAXMAMMSSMASXASMSMXAASAMXSSXSAXMSAMAMAMX"
"XSASXSAXAXAXAMXXSXAAMAAAMASXXMAXAMXAMXMMAMAMMMSXMASMSAXXAXMAMXAAAAAMMSMMMSMMXMAMMMMAMAMAAAMMSMSMMASXMAMXMMAMAMAMXSAAXAMSMMSSMXMAMAMAMXSXMASX"
"XAAAAMXSMMMSMMSAMXSSXMSMSXXAASXMMSSMMMASXMASAAXASXMASXXMXMMSSMSSMMSAXSASXAAXMMAXAAXMSMSMSMMXAAXXSAMXSXSAAMXSAMAXSAMSMSMASMAXAAMXMAMXMAAASAMM"
"SMMMXMMAMAXAAASMXXAXXMAMMASXMMXSAAAAXSAMAXAMMSSMMXMAMAMXMSMAMMMXAXXMMSAMXSXMMSSSMXMAAAMMAMXMMSMMSASXMAMMXMAXMSSMMAMAAXMASMMMSSSMSSSMMSSMMMSS"
"MASXMASASMSSMASMMMAXSMMSMAMMAXAMMSMMMMASMMSSXMAXAXMMSSMAMAXAXXSMMMSAMMAMXXAXAAAAAAMSMMMAMMSAAMAASAMAMSMMSMMSMSAXSAXMXMMXSAXAAXAXXAXXAXAXAXAX"
"SAMXXMSXSMAAMASAXMAXXAASMMMSXMXSAAAAAAXAXAXAAMSSMSAXMAXSSSSMSMMAMXSMMSMMMSMMMSSMMMXMAAMAMAMMXMXXMSMXAAAAXSXAXSAMXXSSMXMSMAMSXSMMMMMMMSMMMMSS"
"MASMSAMXXMSMMASAXMMMMMMMAXAMXSMMXSSMSMMMMSMSMMAAMSASXSMXAAAAAMSAMMMAAAAAXAAAXMAXASXXXMSAMASXSXMSAXMASMMMSMSMMMXMMSAXMASAXAMXMAXAXAAXMAMAAAXS"
"AAAXSAMXMMAMMMSASAMMAAMSMMASASAAXMAAAXAMAMAAMMMXMSAAAMSMMMMSMXSXSAMMMSSMMXMMSXMASMMSXMSMSMSMSAMMAMMAXAMSAXAXMAMAXMASXXSMSXSAMASXSSSXXASMSMMS"
"MMSMMASMASAXXXMMXAXSMMXAASAMXSSMSSMSMSASAMSMSXXAAMXMAMXXXSAMXXMASMMSAAAMSSXSXMAXXXAAAXMXAAXXMAMXAMMSSMMSMSSSSSSSXMXMXMMXXMSMMAMAXMXMSXMAMXAM"
"XAAAMAMXMMAMSASAMSMSAXSAMMASMMAXXAAMAMMMAMXXXASXSMAXMMMMMMMSMMSXSAAMXSMAAASMAXSMSMMSXMXMSSMASXMSSSXMAMAXXXAXAAAMXMAXAAMXMAXAMSSMXSAMXAMMMASM"
"MSSSMASXAMAAXAMXSAASXMAAMSXAXSAMMMAMXMAMXMMAMMMXAMXMXAAAAAXAXASMMMMSMXMMSMMXAMXAAAMMXMAXAAMXMAMXMXXSAMMSSXMMMMMMMSSSSMSAAXSXMMAMXMAMMAMXAXMA"
"MAAXMXSMXMMSMXMXSXMMMSSSMXAAAXASXXASMSSSSSMXMASXMMAMXSSSSSSXMASAAXXXAXMAXMSMSSMSMMAXAXMAMSMSSMMAMAAMASMAMAXAAAMSMMAAMASXSMAXMSAMMMAMXMMASXSX"
"MMSMSXMASXAAMAXXMMMSAMAMAXSMMSMMMSXSAMAAAAMAMMXAASASAMXXAAMAMSMXMMMMSAMXSAAAXXAAXXMSXSASAAXXAXSAMSSMMMMAMXXMSMSAAMAMMAMXXAMMMMMMSSXSAMXAMMXA"
"MAAAXASXMMMSAMXXMASASMAMAMXAXXAAXMAMMMMMMMSASXMMMXASXMXSSSMXMMASXXSAMSSSMMMSMMMXSAMAAXAMMMXMAMXAXXAAAMXASXSXAMSMSMSSXXXXMSMSMMSAMXASMMXAMXMX"
"SSMSMMMAASAMASXMAMSAMXMMAMSAMXMXSMSMMMSAAXSXXXAASMMMMAMXAMMSMMMMMXMASAMAAAXMAMSASXMXSMXMXMAMXMSMMXSMMSMASAAMXMSXXAAAMSSXAAAAAXMASMXMAXXXMAXM"
"AAMXASXXMMASAMAAMXMMMASMSXSAMXAAXAAAAASXSXXAXXSASAMAASAMXMASAXSASASMMMSMMMXSAMAAXMMMXMAXMSAMAMAAMAMAAAMAMMMMSMSXMAMMSMMASXSSSMSMMMXMAXMAMXSA"
"MMMSAMXMXMAMXMMXXMAASXMAXASASXMMSSSSMMSAMMMASAMMSAMXSMSXAMASAMSASASMAXXMASXMASMXMXMASMXSASASXSSSMASMMSMASXASAASASXXXAAAAMXAXXAASAMXMAMSAXAAA"
"XXMMAMXXXMASMXMASMSMSMMAMMMXXXMMAMXXMASAMXSMAMSAMXXXXMMSXSXMXMMXMXMXAMSSSSXMASXSXMMMSAAMXMMMXAMMMMSXMAXMSMSSMSMXMASXSSMXSMAMMSMSXSXMAMSAMXSM";

constant int MAP_SIZE = 140;

constant char PATTERNS[][5] = {
    { 'M', 'M', 'A', 'S', 'S' },
    { 'M', 'S', 'A', 'M', 'S' },
    { 'S', 'M', 'A', 'S', 'M' },
    { 'S', 'S', 'A', 'M', 'M' }
};

constant float3 PALETTE[] = {
    float3(0),
    float3(0.8, 0.2, 0.1),
    float3(0.9, 0.8, 0.6),
    float3(0.1, 0.7, 0.9),
    float3(0.1, 0.2, 0.9)    
};

// returns 0 for no match, 1 to 4 for each type of match
int xmasConvolution(int2 c)
{
    if (c.x < 1 || c.x > MAP_SIZE - 2 || c.y < 1 || c.y > MAP_SIZE - 2)
    {
        // borders
        return 0;
    }
    
    const int2 coords[] = {
        int2(-1,-1),
        int2(-1, 1),
        int2(0, 0),
        int2(1, -1),
        int2(1, 1)
    };
    
    for (int p = 0; p < 4; p++)
    {
        bool match = true;
        for (int i = 0; i < 5; i++)
        {
            int2 ci = c + coords[i];
            int index = ci.y * MAP_SIZE + ci.x;
            if (XMAS_MAP[index] != PATTERNS[p][i])
            {
                match = false;
                break;
            }
        }
        if (match)
        {
            return p + 1;
        }
    }

    // no match
    return 0;
}

// more SDF functions:
// https://iquilezles.org/articles/distfunctions2d/
float sdCircle(float2 p, float r)
{
    return length(p) - r;
}

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

fragment half4 main()
{
    // get int coords
    float size = float(MAP_SIZE);
    int2 iCoord = int2(frag.uv * size);
    // find stars
    int xType = xmasConvolution(iCoord);
    // color by type
    float3 starColor = PALETTE[xType];

    // the stuff below is just to draw a circle in the cell   
    float2 uvCell = fract(size * frag.uv);
    float t = uni.time;
    float2 uv = uvCell * 2 - 1;
    float d = sdCircle(uv, 1);
    // flicker
    float r = nrand(float2(iCoord)/size);
    d *= 1.5*sin(4*t + 2*r) + 1.7;     
    // useful for debugging:
    //float4 out = float4(float2(iCoord)/size, 0, 1);
    //float4 out = float4(uvCell, 0, 1);
    float4 out = float4(starColor * (-d), 1);
    return half4(out);
}