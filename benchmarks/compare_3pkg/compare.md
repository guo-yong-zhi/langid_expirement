## dataset: tatoeba
- LanguageIdentification.jl  
274.189695 seconds (109.33 M allocations: 9.937 GiB, 0.67% gc time, 0.40% compilation time)
- Languages.jl  
247.357442 seconds (149.20 M allocations: 8.386 GiB, 0.59% gc time, 1.49% compilation time)
- LanguageDetect.jl  
1412.815416 seconds (10.90 G allocations: 356.538 GiB, 4.12% gc time, 0.09% compilation time)

|                           | ara        | bel        | ben         | bul        | cat        | ces        | dan        | deu        | ell         | eng        | epo        | fas        | fin        | fra        | hau        | hbs        | heb         | hin        | hun        | ido        | ina        | isl        | ita        | jpn        | kab        | kor         | kur        | lat        | lit        | mar        | mkd        | msa        | nds        | nld        | nor        | pol        | por        | ron        | rus        | slk        | spa        | swa        | swe        | tat        | tgl        | tur        | ukr        | vie         | yid        | zho         |
|---------------------------|------------|------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|-------------|------------|-------------|
| LanguageIdentification.jl | **98.96%** | **97.21%** | **100.00%** | **83.52%** | **93.75%** | **93.07%** | **84.68%** | **98.96%** | **100.00%** | **99.08%** | **97.86%** | **99.04%** | **99.04%** | **97.58%** | **98.81%** |     23.06% |      98.76% |     88.85% | **99.04%** | **90.62%** | **95.30%** | **99.55%** | **96.99%** |     99.97% | **99.43%** | **100.00%** | **99.20%** | **96.53%** | **99.29%** | **88.13%** | **92.96%** | **97.88%** | **96.37%** | **97.76%** | **85.40%** | **99.31%** | **97.68%** | **97.49%** | **91.13%** | **93.26%** | **93.60%** | **98.66%** | **95.50%** | **91.16%** | **98.93%** | **98.94%** | **87.51%** | **100.00%** | **99.31%** | **100.00%** |
|              Languages.jl |     85.55% |     80.47% | **100.00%** |     62.46% |          - |     48.90% |     47.06% |     90.48% |      99.89% |     78.21% |     64.61% |     95.00% |     76.87% |     82.21% |     92.85% | **60.28%** |      95.75% |     62.99% |     73.99% |          - |          - |          - |     66.27% | **99.97%** |          - |      98.97% |          - |          - |     61.94% |     72.05% |     51.40% |     71.26% |          - |     78.91% |     66.74% |     72.66% |     77.35% |     70.87% |     52.59% |          - |     61.89% |          - |     52.46% |          - |     63.96% |     52.10% |     62.63% |      84.06% |     98.39% |      99.86% |
|         LanguageDetect.jl |     94.02% |          - | **100.00%** |     62.94% |     54.33% |     71.15% |     51.46% |     81.94% | **100.00%** |     74.75% |          - |     93.02% |     90.47% |     77.04% |          - |     26.23% | **100.00%** | **93.44%** |     86.66% |          - |          - |          - |     69.37% |     99.87% |          - |      99.48% |          - |          - |     81.73% |     87.09% |     74.60% |     84.28% |          - |     64.61% |     59.33% |     92.55% |     70.50% |     83.24% |     78.56% |     56.46% |     60.08% |     85.32% |     71.20% |          - |     90.83% |     90.30% |     72.24% |      99.75% |          - |      98.59% |

50 columns in total, 39 columns left.
|                           | Average    | ara        | bel        | ben         | bul        | ces        | dan        | deu        | ell         | eng        | epo        | fas        | fin        | fra        | hau        | hbs        | heb        | hin        | hun        | ita        | jpn        | kor         | lit        | mar        | mkd        | msa        | nld        | nor        | pol        | por        | ron        | rus        | spa        | swe        | tgl        | tur        | ukr        | vie         | yid        | zho         |
|---------------------------|------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|-------------|------------|-------------|
| LanguageIdentification.jl | **94.24%** | **98.96%** | **97.21%** | **100.00%** | **83.52%** | **93.07%** | **84.68%** | **98.96%** | **100.00%** | **99.08%** | **97.86%** | **99.04%** | **99.04%** | **97.58%** | **98.81%** |     23.06% | **98.76%** | **88.85%** | **99.04%** | **96.99%** |     99.97% | **100.00%** | **99.29%** | **88.13%** | **92.96%** | **97.88%** | **97.76%** | **85.40%** | **99.31%** | **97.68%** | **97.49%** | **91.13%** | **93.60%** | **95.50%** | **98.93%** | **98.94%** | **87.51%** | **100.00%** | **99.31%** | **100.00%** |
|              Languages.jl |     74.72% |     85.55% |     80.47% | **100.00%** |     62.46% |     48.90% |     47.06% |     90.48% |      99.89% |     78.21% |     64.61% |     95.00% |     76.87% |     82.21% |     92.85% | **60.28%** |     95.75% |     62.99% |     73.99% |     66.27% | **99.97%** |      98.97% |     61.94% |     72.05% |     51.40% |     71.26% |     78.91% |     66.74% |     72.66% |     77.35% |     70.87% |     52.59% |     61.89% |     52.46% |     63.96% |     52.10% |     62.63% |      84.06% |     98.39% |      99.86% |

50 columns in total, 35 columns left.
|                   | Average    | ara        | ben         | bul        | ces        | dan        | deu        | ell         | eng        | fas        | fin        | fra        | hbs        | heb         | hin        | hun        | ita        | jpn        | kor        | lit        | mar        | mkd        | msa        | nld        | nor        | pol        | por        | ron        | rus        | spa        | swe        | tgl        | tur        | ukr        | vie        | zho        |
|-------------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|
|      Languages.jl |     73.65% |     85.55% | **100.00%** |     62.46% |     48.90% |     47.06% | **90.48%** |      99.89% | **78.21%** | **95.00%** |     76.87% | **82.21%** | **60.28%** |      95.75% |     62.99% |     73.99% |     66.27% | **99.97%** |     98.97% |     61.94% |     72.05% |     51.40% |     71.26% | **78.91%** | **66.74%** |     72.66% | **77.35%** |     70.87% |     52.59% | **61.89%** |     52.46% |     63.96% |     52.10% |     62.63% |     84.06% | **99.86%** |
| LanguageDetect.jl | **80.89%** | **94.02%** | **100.00%** | **62.94%** | **71.15%** | **51.46%** |     81.94% | **100.00%** |     74.75% |     93.02% | **90.47%** |     77.04% |     26.23% | **100.00%** | **93.44%** | **86.66%** | **69.37%** |     99.87% | **99.48%** | **81.73%** | **87.09%** | **74.60%** | **84.28%** |     64.61% |     59.33% | **92.55%** |     70.50% | **83.24%** | **78.56%** |     60.08% | **71.20%** | **90.83%** | **90.30%** | **72.24%** | **99.75%** |     98.59% |

50 columns in total, 38 columns left.
|                           | Average    | ara        | ben         | bul        | cat        | ces        | dan        | deu        | ell         | eng        | fas        | fin        | fra        | hbs        | heb         | hin        | hun        | ita        | jpn        | kor         | lit        | mar        | mkd        | msa        | nld        | nor        | pol        | por        | ron        | rus        | slk        | spa        | swa        | swe        | tgl        | tur        | ukr        | vie         | zho         |
|---------------------------|------------|------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|-------------|-------------|
| LanguageIdentification.jl | **93.89%** | **98.96%** | **100.00%** | **83.52%** | **93.75%** | **93.07%** | **84.68%** | **98.96%** | **100.00%** | **99.08%** | **99.04%** | **99.04%** | **97.58%** |     23.06% |      98.76% |     88.85% | **99.04%** | **96.99%** | **99.97%** | **100.00%** | **99.29%** | **88.13%** | **92.96%** | **97.88%** | **97.76%** | **85.40%** | **99.31%** | **97.68%** | **97.49%** | **91.13%** | **93.26%** | **93.60%** | **98.66%** | **95.50%** | **98.93%** | **98.94%** | **87.51%** | **100.00%** | **100.00%** |
|         LanguageDetect.jl |     79.67% |     94.02% | **100.00%** |     62.94% |     54.33% |     71.15% |     51.46% |     81.94% | **100.00%** |     74.75% |     93.02% |     90.47% |     77.04% | **26.23%** | **100.00%** | **93.44%** |     86.66% |     69.37% |     99.87% |      99.48% |     81.73% |     87.09% |     74.60% |     84.28% |     64.61% |     59.33% |     92.55% |     70.50% |     83.24% |     78.56% |     56.46% |     60.08% |     85.32% |     71.20% |     90.83% |     90.30% |     72.24% |      99.75% |      98.59% |

50 columns in total, 35 columns left.
|                           | Average    | ara        | ben         | bul        | ces        | dan        | deu        | ell         | eng        | fas        | fin        | fra        | hbs        | heb         | hin        | hun        | ita        | jpn        | kor         | lit        | mar        | mkd        | msa        | nld        | nor        | pol        | por        | ron        | rus        | spa        | swe        | tgl        | tur        | ukr        | vie         | zho         |
|---------------------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|-------------|-------------|
| LanguageIdentification.jl | **93.77%** | **98.96%** | **100.00%** | **83.52%** | **93.07%** | **84.68%** | **98.96%** | **100.00%** | **99.08%** | **99.04%** | **99.04%** | **97.58%** |     23.06% |      98.76% |     88.85% | **99.04%** | **96.99%** |     99.97% | **100.00%** | **99.29%** | **88.13%** | **92.96%** | **97.88%** | **97.76%** | **85.40%** | **99.31%** | **97.68%** | **97.49%** | **91.13%** | **93.60%** | **95.50%** | **98.93%** | **98.94%** | **87.51%** | **100.00%** | **100.00%** |
|              Languages.jl |     73.65% |     85.55% | **100.00%** |     62.46% |     48.90% |     47.06% |     90.48% |      99.89% |     78.21% |     95.00% |     76.87% |     82.21% | **60.28%** |      95.75% |     62.99% |     73.99% |     66.27% | **99.97%** |      98.97% |     61.94% |     72.05% |     51.40% |     71.26% |     78.91% |     66.74% |     72.66% |     77.35% |     70.87% |     52.59% |     61.89% |     52.46% |     63.96% |     52.10% |     62.63% |      84.06% |      99.86% |
|         LanguageDetect.jl |     80.89% |     94.02% | **100.00%** |     62.94% |     71.15% |     51.46% |     81.94% | **100.00%** |     74.75% |     93.02% |     90.47% |     77.04% |     26.23% | **100.00%** | **93.44%** |     86.66% |     69.37% |     99.87% |      99.48% |     81.73% |     87.09% |     74.60% |     84.28% |     64.61% |     59.33% |     92.55% |     70.50% |     83.24% |     78.56% |     60.08% |     71.20% |     90.83% |     90.30% |     72.24% |      99.75% |      98.59% |

## dataset: wikipedia
- LanguageIdentification.jl  
 78.625558 seconds (73.47 M allocations: 5.228 GiB, 1.15% gc time, 0.12% compilation time)
- Languages.jl  
 38.337676 seconds (105.37 M allocations: 2.444 GiB, 1.14% gc time, 0.89% compilation time)
- LanguageDetect.jl  
 73.265135 seconds (990.87 M allocations: 35.111 GiB, 6.68% gc time, 0.09% compilation time)

|                           | ara        | bel        | ben         | bul        | cat         | ces        | dan        | deu        | ell         | eng         | epo         | fas         | fin        | fra         | hau        | hbs         | heb         | hin        | hun        | ido        | ina        | isl        | ita         | jpn        | kab        | kor         | kur        | lat        | lit         | mar        | mkd        | msa        | nds        | nld        | nor        | pol         | por        | ron        | rus        | slk        | spa         | swa        | swe        | tat        | tgl        | tur        | ukr         | vie        | yid        | zho        |
|---------------------------|------------|------------|-------------|------------|-------------|------------|------------|------------|-------------|-------------|-------------|-------------|------------|-------------|------------|-------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|-------------|------------|------------|-------------|------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|
| LanguageIdentification.jl | **99.50%** | **99.50%** | **100.00%** | **99.00%** | **100.00%** | **96.50%** | **98.50%** | **96.50%** | **100.00%** | **100.00%** | **100.00%** | **100.00%** | **99.50%** | **100.00%** | **99.50%** |      87.00% | **100.00%** |     91.00% | **99.00%** | **92.50%** | **97.00%** | **98.50%** | **100.00%** |     98.00% | **99.00%** | **100.00%** | **99.00%** | **98.50%** | **100.00%** |     95.50% |     97.50% | **99.50%** | **99.50%** | **97.00%** | **98.00%** | **100.00%** | **99.50%** | **90.00%** | **99.50%** | **97.00%** | **100.00%** | **99.50%** | **98.50%** | **99.00%** | **98.50%** | **98.50%** | **100.00%** | **97.00%** | **98.50%** | **99.50%** |
|              Languages.jl |     99.00% |     98.50% |      99.00% | **99.00%** |           - |     92.50% |     88.50% |     96.00% |      96.50% |      99.50% |      96.00% |      98.50% |     98.00% | **100.00%** |     99.00% | **100.00%** |      99.50% |     91.00% |     93.00% |          - |          - |          - |      98.50% | **99.50%** |          - |      89.50% |          - |          - |      94.50% |     95.00% | **98.00%** | **99.50%** |          - |     94.50% |     95.50% |      90.50% |     94.00% |     81.50% |     97.50% |          - |      98.50% |          - |     88.00% |          - |     97.00% |     92.50% |      93.00% |     74.50% |     98.00% |     96.50% |
|         LanguageDetect.jl | **99.50%** |          - | **100.00%** |     80.00% |      76.50% |     84.00% |     65.00% |     82.00% | **100.00%** |      93.00% |           - |      99.00% |     91.50% |      82.50% |          - |       3.50% | **100.00%** | **96.00%** |     94.00% |          - |          - |          - |      85.50% |     95.00% |          - |      95.00% |          - |          - |      97.00% | **98.50%** |     93.00% |     97.50% |          - |     82.50% |     57.50% |      96.00% |     81.50% |     77.50% |     93.00% |     83.00% |      77.50% |     96.00% |     70.00% |          - |     97.50% |     96.50% |      98.50% |     96.50% |          - |     73.00% |

50 columns in total, 39 columns left.
|                           | Average    | ara        | bel        | ben         | bul        | ces        | dan        | deu        | ell         | eng         | epo         | fas         | fin        | fra         | hau        | hbs         | heb         | hin        | hun        | ita         | jpn        | kor         | lit         | mar        | mkd        | msa        | nld        | nor        | pol         | por        | ron        | rus        | spa         | swe        | tgl        | tur        | ukr         | vie        | yid        | zho        |
|---------------------------|------------|------------|------------|-------------|------------|------------|------------|------------|-------------|-------------|-------------|-------------|------------|-------------|------------|-------------|-------------|------------|------------|-------------|------------|-------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|-------------|------------|------------|------------|-------------|------------|------------|------------|
| LanguageIdentification.jl | **98.22%** | **99.50%** | **99.50%** | **100.00%** | **99.00%** | **96.50%** | **98.50%** | **96.50%** | **100.00%** | **100.00%** | **100.00%** | **100.00%** | **99.50%** | **100.00%** | **99.50%** |      87.00% | **100.00%** | **91.00%** | **99.00%** | **100.00%** |     98.00% | **100.00%** | **100.00%** | **95.50%** |     97.50% | **99.50%** | **97.00%** | **98.00%** | **100.00%** | **99.50%** | **90.00%** | **99.50%** | **100.00%** | **98.50%** | **98.50%** | **98.50%** | **100.00%** | **97.00%** | **98.50%** | **99.50%** |
|              Languages.jl |     95.12% |     99.00% |     98.50% |      99.00% | **99.00%** |     92.50% |     88.50% |     96.00% |      96.50% |      99.50% |      96.00% |      98.50% |     98.00% | **100.00%** |     99.00% | **100.00%** |      99.50% | **91.00%** |     93.00% |      98.50% | **99.50%** |      89.50% |      94.50% |     95.00% | **98.00%** | **99.50%** |     94.50% |     95.50% |      90.50% |     94.00% |     81.50% |     97.50% |      98.50% |     88.00% |     97.00% |     92.50% |      93.00% |     74.50% |     98.00% |     96.50% |

50 columns in total, 35 columns left.
|                   | Average    | ara        | ben         | bul        | ces        | dan        | deu        | ell         | eng        | fas        | fin        | fra         | hbs         | heb         | hin        | hun        | ita        | jpn        | kor        | lit        | mar        | mkd        | msa        | nld        | nor        | pol        | por        | ron        | rus        | spa        | swe        | tgl        | tur        | ukr        | vie        | zho        |
|-------------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|-------------|-------------|-------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|
|      Languages.jl | **94.80%** |     99.00% |      99.00% | **99.00%** | **92.50%** | **88.50%** | **96.00%** |      96.50% | **99.50%** |     98.50% | **98.00%** | **100.00%** | **100.00%** |      99.50% |     91.00% |     93.00% | **98.50%** | **99.50%** |     89.50% |     94.50% |     95.00% | **98.00%** | **99.50%** | **94.50%** | **95.50%** |     90.50% | **94.00%** | **81.50%** | **97.50%** | **98.50%** | **88.00%** |     97.00% |     92.50% |     93.00% |     74.50% | **96.50%** |
| LanguageDetect.jl |     86.54% | **99.50%** | **100.00%** |     80.00% |     84.00% |     65.00% |     82.00% | **100.00%** |     93.00% | **99.00%** |     91.50% |      82.50% |       3.50% | **100.00%** | **96.00%** | **94.00%** |     85.50% |     95.00% | **95.00%** | **97.00%** | **98.50%** |     93.00% |     97.50% |     82.50% |     57.50% | **96.00%** |     81.50% |     77.50% |     93.00% |     77.50% |     70.00% | **97.50%** | **96.50%** | **98.50%** | **96.50%** |     73.00% |

50 columns in total, 38 columns left.
|                           | Average    | ara        | ben         | bul        | cat         | ces        | dan        | deu        | ell         | eng         | fas         | fin        | fra         | hbs        | heb         | hin        | hun        | ita         | jpn        | kor         | lit         | mar        | mkd        | msa        | nld        | nor        | pol         | por        | ron        | rus        | slk        | spa         | swa        | swe        | tgl        | tur        | ukr         | vie        | zho        |
|---------------------------|------------|------------|-------------|------------|-------------|------------|------------|------------|-------------|-------------|-------------|------------|-------------|------------|-------------|------------|------------|-------------|------------|-------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|------------|------------|-------------|------------|------------|
| LanguageIdentification.jl | **98.14%** | **99.50%** | **100.00%** | **99.00%** | **100.00%** | **96.50%** | **98.50%** | **96.50%** | **100.00%** | **100.00%** | **100.00%** | **99.50%** | **100.00%** | **87.00%** | **100.00%** |     91.00% | **99.00%** | **100.00%** | **98.00%** | **100.00%** | **100.00%** |     95.50% | **97.50%** | **99.50%** | **97.00%** | **98.00%** | **100.00%** | **99.50%** | **90.00%** | **99.50%** | **97.00%** | **100.00%** | **99.50%** | **98.50%** | **98.50%** | **98.50%** | **100.00%** | **97.00%** | **99.50%** |
|         LanguageDetect.jl |     86.43% | **99.50%** | **100.00%** |     80.00% |      76.50% |     84.00% |     65.00% |     82.00% | **100.00%** |      93.00% |      99.00% |     91.50% |      82.50% |      3.50% | **100.00%** | **96.00%** |     94.00% |      85.50% |     95.00% |      95.00% |      97.00% | **98.50%** |     93.00% |     97.50% |     82.50% |     57.50% |      96.00% |     81.50% |     77.50% |     93.00% |     83.00% |      77.50% |     96.00% |     70.00% |     97.50% |     96.50% |      98.50% |     96.50% |     73.00% |

50 columns in total, 35 columns left.
|                           | Average    | ara        | ben         | bul        | ces        | dan        | deu        | ell         | eng         | fas         | fin        | fra         | hbs         | heb         | hin        | hun        | ita         | jpn        | kor         | lit         | mar        | mkd        | msa        | nld        | nor        | pol         | por        | ron        | rus        | spa         | swe        | tgl        | tur        | ukr         | vie        | zho        |
|---------------------------|------------|------------|-------------|------------|------------|------------|------------|-------------|-------------|-------------|------------|-------------|-------------|-------------|------------|------------|-------------|------------|-------------|-------------|------------|------------|------------|------------|------------|-------------|------------|------------|------------|-------------|------------|------------|------------|-------------|------------|------------|
| LanguageIdentification.jl | **98.09%** | **99.50%** | **100.00%** | **99.00%** | **96.50%** | **98.50%** | **96.50%** | **100.00%** | **100.00%** | **100.00%** | **99.50%** | **100.00%** |      87.00% | **100.00%** |     91.00% | **99.00%** | **100.00%** |     98.00% | **100.00%** | **100.00%** |     95.50% |     97.50% | **99.50%** | **97.00%** | **98.00%** | **100.00%** | **99.50%** | **90.00%** | **99.50%** | **100.00%** | **98.50%** | **98.50%** | **98.50%** | **100.00%** | **97.00%** | **99.50%** |
|              Languages.jl |     94.80% |     99.00% |      99.00% | **99.00%** |     92.50% |     88.50% |     96.00% |      96.50% |      99.50% |      98.50% |     98.00% | **100.00%** | **100.00%** |      99.50% |     91.00% |     93.00% |      98.50% | **99.50%** |      89.50% |      94.50% |     95.00% | **98.00%** | **99.50%** |     94.50% |     95.50% |      90.50% |     94.00% |     81.50% |     97.50% |      98.50% |     88.00% |     97.00% |     92.50% |      93.00% |     74.50% |     96.50% |
|         LanguageDetect.jl |     86.54% | **99.50%** | **100.00%** |     80.00% |     84.00% |     65.00% |     82.00% | **100.00%** |      93.00% |      99.00% |     91.50% |      82.50% |       3.50% | **100.00%** | **96.00%** |     94.00% |      85.50% |     95.00% |      95.00% |      97.00% | **98.50%** |     93.00% |     97.50% |     82.50% |     57.50% |      96.00% |     81.50% |     77.50% |     93.00% |      77.50% |     70.00% |     97.50% |     96.50% |      98.50% |     96.50% |     73.00% |
