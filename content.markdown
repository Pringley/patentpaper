% Techniques for identifying influence in citation networks
% Benjamin Pringle; Mukkai Krishnamoorthy; Kenneth Simons

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
polymer films,[^nplpatent] one of the key advances that lead to the development
of organic LEDs.

Kodak researchers Ching Tang and Steven Van Slyke built on this research in
March 1983 when they filed a new patent demonstrating improved power conversion
in organic electroluminescent devices.[^improvedpowerpatent]

Finally, in October 1987, another group of Kodak scientists patented the first
organic LED device,[^modifiedzone], now used in televisions, monitors, and
phones.

[^nplpatent]: Partridge, Roger. *Radiation Sources.* US3995299 A. Filed October
7, 1975; published Nov 30, 1976.

[^improvedpowerpatent]: Tang, Ching; Van Slyke, Steven. *Organic
electroluminescent devices having improved power conversion efficiencies.*
US4539507 A. Filed March 25, 1983; published September 3, 1985.

[^modifiedzone]: Chen, Chin; Goswami, Ramanuj; Tang, Chin. *Electroluminescent
device with modified thin film luminescent zone.* US4769292 A. Filed October
14, 1987; published Septebmer 6, 1988.

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
text file.[^ledgraphsrc] This was straightforward to read and manipulate using
the Python NetworkX library,[^networkx] used throughout this investigation.

[^ledgraphsrc]: Simons, Ken. **TODO: Source for LED info??**

[^networkx]: Hagberg, Aric; Schult, Dan; Pieter, Swart; et al. *NetworkX:
High-productivity software for complex networks.* Los Alamos National
Laboratory. Version 1.8.1. August 4, 2013.

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

### PageRank
\label{sec:pageranktechnique}

These are the top three patents sorted by PageRank score:

1. US4769292 A -- Kodak 1987
2. US4539507 A -- Kodak 1983
3. US4356429 A -- Kodak 1980

US5247190 A (Cambridge 1990) is ranked seventh.

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

Conclusions
===========
