% Techniques for identifying influence in citation networks
% Benjamin Pringle; Mukkai Krishnamoorthy; Kenneth Simons

\begin{abstract}
Certain patents are historically important or relevant.  We present several
metrics based on network structure to classify or rank the importance of
patents in a citation network.  These metrics can be evaluated by checking
their output against known significant patents. We can then rerun good metrics
on larger sets of patents to discover trends about significant patents.

In this paper, we perform a case study on a set of LED-related patents to
discover if certain authors, companies, or locations correlate with patent
success.
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

Analysis
========

Conclusions
===========
