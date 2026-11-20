# DMDW Practicals: One-Sitting Guide (WEKA)

All 10 practicals use the **WEKA Explorer**. The workflow is always the same:
**Preprocess (load data) → pick a tab (Classify / Cluster / Associate) → Choose algorithm → Start → read output → right-click result to visualize.**

Sample datasets ship with WEKA in its `data/` folder: `weather.nominal.arff`, `weather.numeric.arff`, `iris.arff`, `supermarket.arff`, `ionosphere.arff`.

Suggested order: Exp 1–3 (20 min) → 7, 9, 10 (classification, 40 min) → 5, 6 (clustering, 25 min) → 4 (Apriori, 15 min) → 8 (10 min).

---

## Exp 1: Installation and study of WEKA
- WEKA = Waikato Environment for Knowledge Analysis. It's open-source Java software from the University of Waikato, New Zealand.
- **GUI Chooser** lists 5 apps: **Explorer**, Experimenter, KnowledgeFlow, Workbench, Simple CLI.
- **Explorer tabs:** Preprocess, Classify, Cluster, Associate, Select Attributes, Visualize.
  - Only Preprocess is enabled until you load data.
  - Associate has Apriori, FPGrowth, FilteredAssociator.
  - Cluster has SimpleKMeans, EM, HierarchicalClusterer, FilteredClusterer.

**Try it:** open Explorer and click through every tab.

## Exp 2: Construct ARFF and CSV files
ARFF (Attribute-Relation File Format) has a **header** and a **data** section:
```
@relation weather
@attribute outlook {sunny, overcast, rainy}   % nominal
@attribute temperature real                   % numeric
@attribute humidity real
@attribute windy {TRUE, FALSE}
@attribute play {yes, no}                     % class (last attribute by default)
@data
sunny,85,85,FALSE,no
overcast,83,86,FALSE,yes
rainy,70,96,FALSE,yes
```
- `@relation` = dataset name, `@attribute` = column and its type, `@data` = comma-separated rows. Missing values are written as `?`.
- CSV is the same table with a header row and no type info: `outlook,temperature,humidity,windy,play`.
- **Converting:** open the CSV in Preprocess, then click **Save…** and pick ARFF. You can also go through Tools → ArffViewer.

**Try it:** write the file above in a text editor, save it as `.arff` and as `.csv`, and open both in WEKA.

## Exp 3: Preprocessing
- Load `weather.nominal.arff`. You'll see **Current relation**: 14 instances, 5 attributes.
- Click an attribute to see its type, missing values, distinct and unique counts, and a bar chart of the class split. **Visualize All** shows every attribute at once.
- **Remove:** tick attributes and click Remove. Use it for irrelevant columns.
- **Filters** (Choose → filters):
  - `supervised → attribute → Discretize`: numeric → nominal. Use it on `weather.numeric` (temperature, humidity). Apriori needs nominal data.
  - `supervised → attribute → AttributeSelection`: keeps only the useful attributes (drops temperature and humidity here).
  - Others worth naming in viva: `unsupervised → attribute → ReplaceMissingValues`, `Normalize`, `NumericToNominal`.
- Click **Save…** to keep the cleaned file.

## Exp 4: Apriori (association rule mining)
- Finds **frequent itemsets** (those with support ≥ min support), then builds rules from them (confidence ≥ min confidence).
- **Apriori property:** every subset of a frequent itemset is frequent. That's what lets it prune candidates.
- **Support**(A→B) = P(A∪B), the fraction of transactions containing both A and B.
- **Confidence**(A→B) = support(A∪B) / support(A).
- **Lift** = confidence / support(B). A lift above 1 means a positive correlation.
- **Steps:** load `supermarket.arff` (4627 instances, 217 attributes) → **Associate** tab → Choose **Apriori** → click its name to set `numRules` (default 10), `minMetric` (confidence, default 0.9), `lowerBoundMinSupport` → **Start**. The output lists the best rules, e.g. `biscuits=t frozen foods=t ... ==> bread and cake=t  conf:(0.92)`.
- Use `weather.nominal.arff` for a quick, readable run.

## Exp 5: Hierarchical clustering
- Unsupervised: the class label is not used to build the clusters.
- **Agglomerative** (bottom-up): every point starts as its own cluster and the closest pair is merged repeatedly.
- **Divisive** (top-down): one cluster is split repeatedly.
- **Linkage types:**
  - **single**: minimum distance between clusters.
  - **complete**: maximum distance.
  - **average**: mean distance.
  - (also Ward's, centroid)
- The result is a tree called a **dendrogram**.
- **Steps:** load `iris.arff` (150 instances, 4 numeric attributes + class with 3 values) → **Cluster** tab → Choose `HierarchicalClusterer` → set `numClusters=3` and `linkType` (SINGLE / COMPLETE / AVERAGE) → Cluster mode: **Classes to clusters evaluation** → Start.
- Right-click the result → **Visualize tree** to see the dendrogram. **Visualize cluster assignments** gives the scatter plot.
- The manual also runs **EM** on iris first. EM is probabilistic clustering, and with default settings it picks the number of clusters itself.

## Exp 6: k-means clustering
- **Algorithm:**
  1. Pick k random centroids.
  2. Assign each point to its nearest centroid.
  3. Recompute centroids as cluster means.
  4. Repeat steps 2–3 until nothing changes.
- **Objective:** minimise the within-cluster sum of squared errors (**SSE**).
- **Steps:** `iris.arff` → Cluster → `SimpleKMeans` → click its name and set `numClusters=3` (seed default 10, distanceFunction Euclidean or Manhattan) → Cluster mode **Use training set** (or Classes to clusters) → Start.
- **Output:** number of iterations, within-cluster SSE, a **centroid** (mean vector) per cluster, and instance count and % per cluster.
- Right-click → Visualize cluster assignments.
- **Viva:** you have to choose k yourself. k-means is sensitive to the initial seed and to outliers, and it only uses numeric means.

## Exp 7: J48 decision tree
- J48 is WEKA's Java version of **C4.5** (by Ross Quinlan). It splits on the attribute with the highest **gain ratio** (an information-gain/entropy measure), handles numeric attributes and missing values, and prunes the tree.
- **Entropy** H = −Σ p·log₂p. **Information gain** = H(parent) − weighted H(children).
- **Steps:** load `weather.nominal.arff` → **Classify** → Choose `trees → J48` → Test options **Cross-validation, 10 folds** → Start.
- **Output:** the tree as text, *Number of leaves*, *Size of tree*, the Summary (correctly classified %, Kappa, MAE, RMSE), *Detailed accuracy by class* (TP rate, FP rate, Precision, Recall, F-measure, ROC area) and the **Confusion matrix**.
- Right-click → **Visualize tree**. Visualize classifier errors: crosses are correct, squares are wrong.
- **Params:** `confidenceFactor` (0.25; lower means more pruning), `minNumObj` (2), `unpruned`.

## Exp 8: Random Tree / Random Forest
- **RandomTree:** a single tree that only considers **K random attributes** at each split, with no pruning.
- **RandomForest:** many random trees, each trained on a **bootstrap sample** (bagging); predictions are combined by majority vote. It's more accurate and less overfit than one tree.
- **Steps:** load `ionosphere.arff` → Classify → `trees → RandomTree` → Start. Then `trees → RandomForest` → Start (default params; around 92–93% accuracy). Compare the two.
- **Params:** `numFeatures` / `KValue` (0 = auto, about log₂(attributes)+1), `numIterations` (number of trees, default 100), `seed`.

## Exp 9: Naive Bayes
- **Bayes' theorem:** P(C|X) = P(X|C)·P(C) / P(X).
- **"Naive"** means attributes are assumed independent given the class, so P(X|C) = Π P(xᵢ|C).
- The model predicts the class with the highest posterior.
- **Steps:** `weather.nominal.arff` → Classify → `bayes → NaiveBayes` → Test options **Percentage split 66%** (≈9 train, 5 test of 14) → Start.
- **Output:** a table of counts/probabilities per attribute value per class (the "statistical analysis" part), then accuracy and the confusion matrix.
- **Params:** `useKernelEstimator` (for numeric attributes instead of a normal distribution), `useSupervisedDiscretization`.
- **Hand example for viva:**
  - P(yes)=9/14, P(no)=5/14.
  - For outlook=sunny, temp=cool, humidity=high, windy=true:
    - yes: 9/14 · 2/9 · 3/9 · 3/9 · 3/9 ≈ 0.0053
    - no: 5/14 · 3/5 · 1/5 · 4/5 · 3/5 ≈ 0.0206
  - Prediction: **no**.

## Exp 10: Performance metrics
Confusion matrix (rows = actual, columns = predicted):

|            | Pred Yes | Pred No |
|------------|----------|---------|
| Actual Yes | TP       | FN      |
| Actual No  | FP       | TN      |

**Classification metrics:**
- **Accuracy** = (TP+TN)/(TP+TN+FP+FN)
- **Precision** = TP/(TP+FP): of the predicted positives, how many were right.
- **Recall / Sensitivity / TPR** = TP/(TP+FN): of the actual positives, how many were caught.
- **F1** = 2·P·R/(P+R): harmonic mean of precision and recall.
- **FPR** = FP/(FP+TN). **Specificity** = 1 − FPR.
- **ROC** plots TPR against FPR across thresholds. **AUC** = area under that curve: 1 is perfect, 0.5 is random.

**Regression metrics:**
- **MAE** = (1/N)Σ|y−ŷ|
- **MSE** = (1/N)Σ(y−ŷ)². **RMSE** = √MSE.
- **R²** = 1 − SS_res/SS_tot
- **Adjusted R²** = 1 − (1−R²)(n−1)/(n−k−1)

**Test options in WEKA:**
- **Use training set**: optimistic.
- **Supplied test set**.
- **Cross-validation (k folds)**: data split into k parts; each part is the test set once.
- **Percentage split**: e.g. 66% train.

**Steps:** run J48, NaiveBayes and RandomForest on the same dataset with 10-fold CV and compare accuracy, precision, recall, F1 and ROC area from "Detailed Accuracy By Class". Right-click a result → **Visualize threshold curve** to get the ROC curve.

---

## Quick viva one-liners
- **Supervised vs unsupervised:** classification uses class labels; clustering and association don't.
- **Data mining vs data warehouse:** mining finds patterns; a warehouse stores integrated historical data (subject-oriented, integrated, time-variant, non-volatile).
- **KDD steps:** cleaning → integration → selection → transformation → mining → evaluation → presentation.
- **Why discretize before Apriori?** Apriori only works on nominal/binary items.
- **Overfitting:** the model memorises the training data. Fixes include pruning in J48 and averaging many trees in a Random Forest.
- **Kappa statistic:** agreement beyond chance. 1 is perfect, 0 is chance level.
