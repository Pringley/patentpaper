---
title: Techniques for identifying influence in citation networks
author: Benjamin Pringle; Mukkai Krishnamoorthy; Kenneth Simons
numbersections: true
header-includes:
 - \setlength{\parskip}{0.0pt plus 1.0pt}
 - \setlength{\parindent}{15.0pt}
cs1: acm-sig-proceedings.csl
references:
 - id: nplpatent
   title: Radiation Sources
   author: Roger Partridge
   type: patent
   number: US3995299 A
   issued:
    date-parts:
     - - 1976
       - 11
       - 30
 - id: improvedpowerpatent
   title: Organic electroluminescent devices having improved power conversion efficiencies
   authors:
    - Ching Tang
    - Steven Van Slyke
   type: patent
   number: US4539507 A
   issued:
    date-parts:
     - - 1985
       - 9
       - 3
 - id: modifiedzone
   title: Electroluminescent device with modified thin film luminescent zone
   authors:
    - Ching Tang
    - Chin Chen
    - Ramanuj Goswami
   type: patent
   number: US4769292 A
   issued:
    date-parts:
     - - 1988
       - 9
       - 6
---

\begin{abstract}
Certain patents are historically important or relevant.  We present several
metrics based on network structure to classify or rank the importance of
patents in a citation network.  These metrics can be evaluated by checking
their output against known significant patents. We can then rerun good metrics
on larger sets of patents to discover trends about significant patents.

In this paper, we perform a case study on a set of LED-related patents to
assess the contributions of various companies to the field.
\end{abstract}

Background
==========

Citation network analysis
-------------------------

A subfield of link analysis, citation analysis deals with networks formed by
citations in articles, books, patents, or other scholarly works.

We will utilize well-established techniques from link analysis, such as Page
Rank (Section \ref{sec:pageranktechnique}) and HITS
(Section \ref{sec:hitstechnique}), then introduce our own modified and new
techniques that are better suited to specifically citation analysis.

Important LED patents
---------------------
\label{sec:ledbgnd}

In October 1975, Roger Partridge with the National Physics Laborotory in the
United Kingdom filed the first patent demonstrating electroluminescence from
polymer films [@nplpatent], one of the key advances that lead to the development
of organic LEDs.

Kodak researchers built on this research in March 1983 when they filed a new
patent demonstrating improved power conversion in organic electroluminescent
devices [@improvedpowerpatent].

Finally, in October 1987, another group of Kodak scientists patented the first
organic LED device [@modifiedzone], now used in televisions, monitors, and
phones.


Data format and representation
------------------------------

![OLED citation network \label{fig:olednet}](images/oled-graph.pdf)

A citation graph has nodes representing scholarly works and directed edges
representing citations between them. The edges are directed from *cited node to
citing node*, or in the direction of time. This way, the nodes represent "flow
of knowledge/influence."

Figure \ref{fig:olednet} shows a very simple example drawn from the patents
described in Section \ref{sec:ledbgnd}.

Our citation graph was supplied as simply a list of tab-separated edges in a
text file.[^ledgraphsrc]

```
citingApplnID	citedApplnID
46015030	1226
46332773	1226
49212827	1226
...
```

We developed an open source tool called CiteNet[^citenet] to read and analyze
data of this sort. Below is a subset of the configuration used (the full
configuration is available in Appendix \ref{sec:cnconfig}).

    {
        "graph": {
            "filename": "...",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "reverse_edges": true,
            "suppress_warnings": true,
            "ignore_header": true
        },
        ...
    }

This was straightforward to read and manipulate using
the Python NetworkX library,[^networkx] used throughout this investigation.

[^ledgraphsrc]: Simons, Ken. **TODO: Source for LED info??**

[^networkx]: Hagberg, Aric; Schult, Dan; Pieter, Swart; et al. *NetworkX:
High-productivity software for complex networks.* Los Alamos National
Laboratory. Version 1.8.1. August 4, 2013.

[^citenet]: Pringle, Ben. *CiteNet.* <https://github.com/Pringley/citenet>

Techniques
==========

This section is split into two parts. In Section \ref{sec:nodetechniques}, we
present techniques to rank the impact of individual nodes. In Section
\ref{sec:metatechs}, we present methods of generalizing these node-based
techniques to draw conclusions about graph metadata.

Node ranking techniques
-----------------------
\label{sec:nodetechniques}

### Highest outdegree

The simplest method for determining the importance of a node in a citation
network is to simply count the number of times the node is cited -- that is, a
node with high outdegree is considered more important.

These are the top three patents sorted by outdegree:

1. US4769292 A (444 citations) -- Kodak 1987
2. US4539507 A (360 citations) -- Kodak 1983
3. US5247190 A (339 citations) -- Cambridge 1990

The top two are directly from our summary in Section \ref{sec:ledbgnd}, which
validates this choice as relatively good.

### PageRank
\label{sec:pageranktechnique}

These are the top three patents sorted by PageRank score:

1. US4769292 A -- Kodak 1987
2. US4539507 A -- Kodak 1983
3. US4356429 A -- Kodak 1980

US5247190 A (Cambridge 1990) is ranked seventh. PageRank doesn't seem to differ
much from highest outdegree in terms of output.

### HITS
\label{sec:hitstechnique}

These are the top three patents sorted by Hub score from the HITS algorithm:

1. US4918497 A -- Cree 1988
2. US4966862 A -- Cree 1989
3. ***\* unknown id***

These patents have outdegree of 120 and 110 respectively, and would be ranked
38th and 43rd by outdegree.

(The third node exists in the data graph but is missing any metadata to
identify which patent it corresponds to.)

### Neighborhood size

One new metric we explored was neighborhood size -- rank nodes by the number of
other nodes that can be reached within a fixed number of forward edges. These
are the top three patents sorted by 2-neighborhood:

1. US6791119 B2 -- Cree 2002
2. US6830828 B2 -- Princeton 2001
3. US6175345 B1 -- Canon 1998

Metadata techniques
-------------------
\label{sec:metatechs}

### Summed node scores

The simplest way to generalize a node-based technique to a metadata field is to
set the metadata score equal to the sum of the node scores.

```python
for node in nodes
    score = get_score(node)
    val = node[field]
    sums[val] += score
return sums
```

### Normalized summed scores

We can reduce the impact of a metadata value's frequency by normalizing the
sums -- that is, divide each sum by the total number of nodes with that value.

```python
for val, sum in sums
    norm_factor = count(nodes with val)
    norm_sums = sum[val] / norm_factor
return norm_sums
```

In other words, this is the *mean* score for nodes with a given metadata value.

### Contribution factor

Another approach is to look at all nodes contributed by a certain metadata
value and count the *percentage* that score above a particular cutoff.

```python
for node in nodes:
    score = get_score(node)
    val = node[field]
    if score > cutoff:
        contrib_counts[val] += 1
    total_counts[val] += 1
for val in vals:
    contrib[val] = (contrib_counts[val]
                    / total_counts[val])
```

Analysis
========

Choosing a metric for company size
----------------------------------

We would like to explore whether company size has any correlation with patent
quality.  Do big innovations originate from big labs, or do smaller companies
pave the way (only to be later acquired)?

In order to begin this investigation, we need a solid metric to quantify
"company size." Our first thought was to use a metadata-based solution, such as
the company's net worth or number of employees. However, it wasn't clear at
*which point in time* to measure the company size -- does a company's employee
count in 2013 affect the quality of a patent it filed in the 1980s?

Instead, we choose a very simple metric contained within our dataset: company
size is defined as the **number of patents submitted**.

This may not be a perfect representation of "size," but it still allows us to
analyze whether these "prolific" companies are contributing any *important*
patents or merely a large volume of consequential patents.

Our set of "big companies" will therefore be the 25 companies that applied for
the largest number of patents. They are, in order with number of LED patents
each:

> `samsung` (1673), `semiconductor energy lab` (1437), `seiko` (1394), `sharp`
> (1103), `panasonic` (1094), `sony` (937), `toshiba` (848), `sanyo (tokyo
> sanyo electric)` (793), `philips` (789), `kodak` (767), `hitachi` (632),
> `osram` (631), `nec` (621), `lg` (613), `idemitsu kosan co` (553), `canon`
> (538), `pioneer` (525), `mitsubishi` (501), `rohm` (420), `tdk` (384),
> `nichia` (370), `fujifilm` (369), `ge` (363), `sumitomo` (323), `lg/philips`
> (293)

Summed outdegree
----------------

The "summed score" metric isn't very useful in this situation, since we've
already ranked our patents by frequency in our definition of company size. The
summed score for outdegree gives us little new information.

Below is our list of top 25 patents, with their relative ranking by summed
outdegree score in parentheses:

> `samsung` (2), `semiconductor energy lab` (1), `seiko` (3), `sharp` (5),
> `panasonic` (6), `sony` (7), `toshiba` (8), `sanyo (tokyo sanyo electric)`
> (10), `philips` (9), `kodak` (4), `hitachi` (15), `osram` (14), `nec` (11),
> `lg` (17), `idemitsu kosan co` (12), `canon` (16), `pioneer` (13),
> `mitsubishi` (18), `rohm` (22), `tdk` (20), `nichia` (19), `fujifilm` (25),
> `ge` (21), `sumitomo` (26), `lg/philips` (27)

As expected, our top-frequency companies have very high rankings by summed
outdegree score.

Normalized summed outdegree
---------------------------

Instead, we can look at the *normalized* outdegree, or the mean outdegree of a
patent produced by one of our companies. Let's take a look at just our top 10
companies:

1. `samsung` -- 11.51
2. `semiconductor energy lab` -- 14.91
3. `seiko` -- 13.06
4. `sharp` -- 13.39
5. `panasonic` -- 13.13
6. `sony` -- 13.23
7. `toshiba` -- 14.22
8. `sanyo (tokyo sanyo electric)` -- 13.86
9. `philips` -- 14.47
10. `kodak` -- 19.98

By comparison, the mean outdegree over *all* patents is 5.60.

Contribution factor -- outdegree
--------------------------------

Let us define patents as relatively significant if their outdegree is in the
75th percentile. (For our LED dataset, this includes all patents with at least
11 citations.)

Then, we can calculate contribution factors for each company by finding the
fraction of their patents that are considered relatively significant. Here are
the results:

1. `samsung` -- .63
2. `semiconductor energy lab` -- .85
3. `seiko` -- .78
4. `sharp` -- .86
5. `panasonic` -- .85
6. `sony` -- .82
7. `toshiba` -- .89
8. `sanyo (tokyo sanyo electric)` -- .88
9. `philips` -- .76
10. `kodak` -- .84

Date partitioning
-----------------

Another interesting approach is to look at the filing date of the patents.
Below is a histogram of number of patents by filing date.

```
date range	                count
1940-11-12 to 1945-07-06	1
1945-07-06 to 1950-02-28	6
1950-02-28 to 1954-10-23	107
1954-10-23 to 1959-06-17	247
1959-06-17 to 1964-02-09	369
1964-02-09 to 1968-10-03	344
1968-10-03 to 1973-05-28	362
1973-05-28 to 1978-01-20	575
1978-01-20 to 1982-09-14	678
1982-09-14 to 1987-05-09	1125
1987-05-09 to 1992-01-01	2257
1992-01-01 to 1996-08-25	3451
1996-08-25 to 2001-04-19	8103
2001-04-19 to 2005-12-12	16019
2005-12-12 to 2010-08-06	5040
```

We can partition each company's patents into thirds -- that is, `samsung0`
contains the first chronological third of Samsung's patents, `samsung1`
contains the second third, and `samsung2` contains the final third.

We can calculate normalized outdegree for each third:

```
company    partition  start       end         normalizedoutdeg    count  totalcount
samsung    0          1989-05-30  2004-06-28  2.6858168761220824  557    1673
samsung    1          2004-06-28  2005-11-30  1.3375224416517055  557    1673
samsung    2          2005-12-02  2010-07-13  0.5116279069767442  559    1673
sel        0          1982-02-09  2002-02-26  8.187891440501044   479    1437
sel        1          2002-02-28  2004-06-23  5.1941544885177455  479    1437
sel        2          2004-06-25  2010-01-06  1.3528183716075157  479    1437
seiko      0          1973-07-13  2002-02-22  5.644396551724138   464    1394
seiko      1          2002-02-25  2004-01-21  2.543103448275862   464    1394
seiko      2          2004-01-21  2009-06-18  0.9978540772532188  466    1394
sharp      0          1972-07-31  1994-02-22  4.809264305177112   367    1103
sharp      1          1994-02-25  2001-10-29  3.5476839237057223  367    1103
sharp      2          2001-10-31  2010-02-26  1.8130081300813008  369    1103
panasonic  0          1963-11-18  1997-10-31  3.4148351648351647  364    1094
panasonic  1          1997-11-05  2002-02-21  3.6950549450549453  364    1094
panasonic  2          2002-02-27  2010-03-05  2.2868852459016393  366    1094
sony       0          1970-04-13  2000-09-11  4.064102564102564   312    937
sony       1          2000-09-14  2003-08-20  4.0576923076923075  312    937
sony       2          2003-08-28  2010-02-10  1.5878594249201279  313    937
toshiba    0          1969-08-25  1993-03-30  4.184397163120567   282    848
toshiba    1          1993-04-13  2001-04-27  6.1063829787234045  282    848
toshiba    2          2001-04-27  2010-03-23  2.3732394366197185  284    848
sanyo      0          1976-12-09  2000-03-17  6.943181818181818   264    793
sanyo      1          2000-03-17  2003-03-28  3.25                264    793
sanyo      2          2003-03-28  2009-01-15  1.4037735849056603  265    793
philips    0          1954-01-29  1999-09-08  6.011406844106464   263    789
philips    1          1999-09-08  2004-07-01  6.068441064638783   263    789
philips    2          2004-07-09  2009-06-03  1.326996197718631   263    789
kodak      0          1965-03-25  2001-01-30  23.63529411764706   255    767
kodak      1          2001-02-02  2003-09-23  4.670588235294118   255    767
kodak      2          2003-09-24  2008-02-25  1.7042801556420233  257    767
```

Conclusions
===========

Based on our meta-metrics, it seems that while big companies file many patent
applications, these patents are *not* any lower quality than average.

By the normalized summed outdegree measure, the top 10 companies each had a
mean outdegree more than *double* that of the entire dataset.

By contribution factor analysis, each of the top 10 (except Samsung) still
exceeded the expected ratio.

\appendix

CiteNet
=======

Config
------

\label{sec:cnconfig}

```
{
    "graph": {
        "filename": "citation pairs by applnID simple try sorted by cited.txt",
        "delimiter": "\t",
        "encoding": "ISO-8859-1",
        "reverse_edges": true,
        "suppress_warnings": true,
        "ignore_header": true
    },
    "metadata": [
        {
            "filename": "LEDs patents keyinfo.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "suppress_warnings": true,
            "id_field": "applnID"
        },
        {
            "filename": "LEDs patents applicants longform.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "suppress_warnings": true,
            "id_field": "applnID"
        }
    ],
    "reports": [
        {
            "function": "metadata_histogram",
            "output": "reports/company_histogram.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "options": {
                "field": "appMyName"
            }
        },
        {
            "function": "date_histogram",
            "output": "reports/date_histogram.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "options": {
                "date_field": "applnFilingDate",
                "date_format": "%d%b%Y",
                "bins": 15
            }
        },
        {
            "function": "citation_histogram",
            "output": "reports/citation_histogram.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "options": {
                "date_field": "applnFilingDate",
                "date_format": "%d%b%Y",
                "bins": 15
            }
        },
        {
            "function": "normalized_outdegree_by_date_and_metadata",
            "output": "reports/normalized_outdegree_by_company_and_date.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "options": {
                "field": "appMyName",
                "date_field": "applnFilingDate",
                "date_format": "%d%b%Y",
                "bins": 3
            }
        },
        {
            "function": "normalized_outdegree_by_metadata",
            "output": "reports/normalized_outdegree_by_company.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "options": {
                "field": "appMyName"
            }
        },
        {
            "function": "outdegree_histogram",
            "output": "reports/outdegree_histogram.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "options": {}
        },
        {
            "function": "good_outdegree_ratio_by_metadata",
            "output": "reports/good_outdegree_ratio_by_company.txt",
            "delimiter": "\t",
            "encoding": "ISO-8859-1",
            "options": {
                "field": "appMyName",
                "ratio_cutoff": 0.25
            }
        }
    ],
    "options": {
        "cache_reports": false
    }
}
```

Works Cited
===========
