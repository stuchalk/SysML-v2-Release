standard library package Occurrences {
	doc
	/*
	 * This package defines modeling constructs for anything existing or occurring in time and space, with
	 * associations between them that assert temporal and spatial relationships.
	 */

	private import Base::Anything;
	private import Base::things;
	private import Base::DataValue;
	private import ScalarValues::Natural;
	private import ScalarValues::Boolean;
	private import Links::*;
	private import Clocks::*;
	private import Collections::Set;
	private import Collections::OrderedSet;
	private import CollectionFunctions::contains;
	private import SequenceFunctions::isEmpty;
	private import SequenceFunctions::notEmpty;
	private import SequenceFunctions::includes;
	private import SequenceFunctions::union;

	/*
	 * Occurrence is the most general classifier of entities that have identity and
	 * occur over time and space.
	 *
	 * The features of Occurrence specify the semantics of associations between occurrences that
	 * assert complete inclusion and exclusion in time or space, or both, which includes
	 * portions of an occurrence (having the same identity).  Portions include slices and shots
	 * over time and space.
	 */
	abstract class Occurrence specializes Anything {
		private import SequenceFunctions::*;

		feature portionOfLife: Life[1] subsets portionOf;

		feature self: Occurrence[1] redefines Anything::self subsets timeSlices, spaceSlices, sameLifeOccurrences;
		feature sameLifeOccurrences: Occurrence[1..*] subsets things;

		feature this : Occurrence[1] default self {
			doc
			/*
			 * The "context" Occurrence within which this Occurrence takes place. By default, it is this
			 * Occurrence itself. However, this is overridden for ownedPerformances of Objects and
			 * subperformances of Performances.
			 */
		}
		connector :HappensDuring from self[1] to this[1];
		
		feature localClock : Clock[1] default universalClock  {
			doc
			/*
			 * A local Clock to be used as the corresponding time reference for this Occurrence
			 * and, by default, all ownedOccurrences. By default this is the singleton universalClock.
			 */
		}
		
		composite feature suboccurrences: Occurrence[0..*] subsets occurrences {
			doc
			/*
			 * Composite suboccurrences of this Occurrence.
			 */
			 
			 feature redefines localClock default (that as Occurrence).localClock {
			 	doc
			 	/*
			 	 * The localClock of a suboccurrence defaults to the localClock of its containing
			 	 * Occurrence.
			 	 */
			 }
			 
			 feature redefines incomingTransferSort default (that as Occurrence).incomingTransferSort;
		}
		
		feature predecessors: Occurrence[0..*] subsets occurrences {
			doc
			/*
			 * Occurrences that end before this occurrence starts.
			 */
		}

		feature successors: Occurrence[0..*] subsets occurrences {
			doc
			/*
			 * Occurrences that start after this occurrence ends.
			 */
		}

		feature immediatePredecessors: Occurrence[0..*] subsets predecessors {
			doc
			/*
			 * Occurrences that end just before this occurrence starts, with no
			 * possibility of other occurrences happening in the time between them.
			 */
		}

		feature immediateSuccessors: Occurrence[0..*] subsets successors {
			doc
			/*
			 * Occurrences that start just after this occurrence ends, with no
			 * possibility of other occurrences happening in the time between them.
			 */
		}

		feature timeEnclosedOccurrences: Occurrence[1..*] subsets occurrences {
			doc
			/*
			 * Occurrences that start no earlier than and end no later than
			 * this occurrence, including at least this occurrence.
			 */
		}

		feature spaceEnclosedOccurrences: Occurrence[1..*] subsets occurrences {
			doc
			/*
			 * Occurrences that this one completely includes in space (not necessarily in time),
			 * including this one.
			 */
		}

		feature spaceTimeEnclosedOccurrences: Occurrence[1..*] subsets timeEnclosedOccurrences, spaceEnclosedOccurrences {
			doc
			/*
			 * Occurrences that this one completely includes in both space and time,
			 * including this one.
			 */
		}

		feature all spaceTimeEnclosedPoints : Occurrence[1..*] subsets spaceTimeEnclosedOccurrences {
			doc
			/*
			 * All space time enclosed occurrences that take up zero time and space.
			 */

			redefines innerSpaceDimension = 0;
			binding startShot[1] = endShot[1];
		}

		feature spaceTimeCoincidentOccurrences: Occurrence[1..*] subsets spaceTimeEnclosedOccurrences {
			doc
			/*
			 * Occurrences that this one completely includes in both space and time,
			 * and vice-versa, including this one.
			 */
		}

		feature matingOccurrences: Occurrence[1..*] subsets occurrences {
			doc
			/*
			 * Occurrences that have no space between them and this one.
			 */
		}

		feature innerSpaceDimension : Natural [1] {
			doc
			/*
			 * The number of variables needed to identify space points in this occurrence, from 0
			 * to 3, without regard to higher dimensional spaces it might be embedded in.
			 */
		}

		inv { innerSpaceDimension <= 3 }

		feature outerSpaceDimension : Natural [0..1] {
			doc
			/*
			 * For occurrences of innerSpaceDimension 1 or 2, the number of variables needed to
			 * identify their space points in higher dimensions they might be embedded in, from
			 * the innerSpaceDimension to 3. An outerSpaceDimension equal to innerSpaceDimension
			 * indicates the occurrence is spatially straight (innerSpaceDimension 1 embedded in
			 * 2 or 3 dimensions) or flat (innerSpaceDimension 2 embedded in 3 dimensions).
			 */
		}
		inv { notEmpty(outerSpaceDimension) implies
			 (outerSpaceDimension >= innerSpaceDimension & outerSpaceDimension <= 3) }

		portion feature all portions: Occurrence[1..*] subsets spaceTimeEnclosedOccurrences {
			doc
			/*
			 * All spaceTimeEnclosedOccurrences that have the same portionOfLife (considered the same
			 * thing occurring), see PortionOf.
			 */
		}

		feature portionOf : Occurrence[1..*] {
			doc
			/*
			 * Occurrences of which this occurrence is a portion, including at
			 * least this occurrence.
			 */
		}

		portion feature timeSlices: Occurrence[1..*] subsets portions {
			doc
			/*
			 * Portions of an occurrence taking up all of its space over some period of time,
			 * including at least this occurrence.
			 */
		}

		feature timeSliceOf : Occurrence[1..*] subsets portionOf {
			doc
			/*
			 * Occurrences of which this occurrence is a time slice, including at least this
			 * occurrence.
			 */
		}

		portion feature all snapshots: Occurrence[1..*] subsets timeSlices {
			doc
			/*
			 * Time slices of an occurrence that happen at a single instant of time
			 * (i.e., have no duration).
			 */
			binding startShot[1] = endShot[1];
		}
		inv { snapshots == union(startShot, union(middleTimeSlice.snapshots, endShot)) }

		feature snapshotOf : Occurrence[0..*] subsets timeSliceOf {
			doc
			/*
			 * Occurrences of which this occurrence is a snapshot.
			 */
		}

		portion feature startShot: Occurrence[1] subsets snapshots {
			doc
			/*
			 * The snapshot representing the start of the occurrence in time.
			 */
		}

		portion feature middleTimeSlice: Occurrence[0..1] subsets timeSlices {
			doc
			/*
			 * A time slice that takes all the time between the start shot and end shot. There
			 * is none when the startShot and endShot are the same.
			 */
		}
		inv { isEmpty(middleTimeSlice) == (startShot == endShot) }

		connector :HappensJustBefore
			from earlierOccurrence references startShot [1]
			to laterOccurrence references middleTimeSlice [0..1] {
			doc
			/*
			 * The startShot happens immediately before the middle time slice.
			 */
		}

		portion feature endShot: Occurrence[1] subsets snapshots {
			doc
			/*
			 * The snapshot at the end of the occurrence in time.
			 */
		}

		 connector :HappensJustBefore
			from earlierOccurrence references middleTimeSlice [0..1]
			to laterOccurrence references endShot [1] {
			doc
			/*
			 * The endShot happens after the middle time slice.
			 */
		}

		portion feature spaceSlices: Occurrence[1..*] subsets portions {
			doc
			/*
			 * Portions of this occurrence that extend for exactly the same time and some or all
			 * the space, relative to spatial location of this occurrence, including at least
			 * this occurrence.
			 */
		}

		feature spaceSliceOf: Occurrence[1..*] subsets portionOf {
			doc
			/*
			 * Occurrences of which this occurrence is a space slice, including at least this
			 * occurrence.
			 */
		}

		portion feature spaceShots: Occurrence[1..*] subsets spaceSlices {
			doc
			/*
			 * All spaceSlices of this occurrence that are of a lower inner space dimension than it.
			 */
		}

		feature spaceShotOf: Occurrence[0..*] subsets spaceSliceOf {
			doc
			/*
			 * Occurrences of which this occurrence is a space shot.
			 */
		}

		feature unionsOf: Set[0..*] {
			doc
			/*
			 * Sets of occurrences, where the time and space taken by all the occurrences in each
			 * set together is the same as taken by this occurrence (all four dimensional points in
			 * the occurrences of each set are at the same time and space as those of this
			 * occurrence).
			 */

			feature redefines elements: Occurrence[0..*];
			feature union: Occurrence[0..1];

			connector :Within
				  from smallerOccurrence references elements [0..*]
				  to largerOccurrence references union [1];
			connector :Within
				  from smallerOccurrence references union.spaceTimeEnclosedPoints [0..*]
				  to largerOccurrence references elements [1..*];
		}
		binding unionsOf.union[0..1] = self[1];

		feature intersectionsOf: Set[0..*] {
			doc
			/*
			 * Sets of occurrences, where the time and space taken in common between the occurrences
			 * in each set is at the same as taken by this occurrence (all four dimensional points
			 * common to the occurrences in each set are at the same time and space as those in this
			 * occurrence).
			 */

			feature redefines elements: Occurrence[0..*] {
				feature all notIntersection: Occurrence[0..*] subsets spaceTimeEnclosedPoints;
			}
			feature intersection: Occurrence[0..1];

			connector :Within
				  from smallerOccurrence references intersection [1]
				  to largerOccurrence references elements [0..*];
			connector :Without
				  from separateOccurrenceToo references elements.notIntersection [0..*]
				  to separateOccurrence references intersection [1];
			connector :Without
				  from separateOccurrenceToo references elements.notIntersection [0..*]
				  to separateOccurrence references elements [1..*];
		}
		binding intersectionsOf.intersection[0..1] = self[1];

		feature differencesOf: OrderedSet[0..*] {
			doc
			/*
			 * Ordered sets of occurrences, where the time and space taken by first occurrence in
			 * each set that is not in the time and space taken by the remaining occurrences is the
			 * same as taken by this occurrence (all four dimensional points in the minuend that are
			 * not in any subtrahend are at the same time and space as those in this occurrence).
			 */
			feature redefines elements: Occurrence[0..*];
			feature difference: Occurrence[0..1];
			feature minuend: Occurrence [0..1] subsets elements, interdiff.elements = head(elements);
			feature subtrahend: Occurrence[*] subsets elements = tail(elements);
			feature interdiff: Set [0..1] {
				feature redefines elements: Occurrence[1..*];
				feature all notSubtrahend: Occurrence [0..*] subsets elements;
			}

			connector :Without
				  from separateOccurrenceToo references interdiff.notSubtrahend [0..*] 
				  to separateOccurrence references subtrahend [1..*];

			inv { isEmpty(difference) == isEmpty(interdiff) }
			inv { notEmpty(difference) implies (difference.intersectionsOf == interdiff) }
		}
		binding differencesOf.difference[0..1] = self[1];

		portion feature spaceInterior: Occurrence[0..1] subsets spaceSlices {
			doc
			/*
			 * A space slice of this occurrence that includes all its space shots except the
			 * space boundary, which must exist and be outsideOf it.  The space interior must be
			 * of the same inner space dimension as this occurrence, except if it is zero,
			 * whereupon there is no space interior.
			 */
		}

		feature spaceInteriorOf: Occurrence[0..1] subsets spaceSliceOf {
			doc
			/*
			 * An Occurrence of which this one is the space interior.
			 */
		}

		inv { notEmpty(spaceInterior) implies spaceInterior.innerSpaceDimension == innerSpaceDimension }

		portion feature spaceBoundary: Occurrence[0..1] subsets spaceShots {
			doc
			/*
			 * A space shot of this Occurrence that is not among those of its space interior,
			 * which must be outside it. It must not have a spaceBoundary.	It can be divided
			 * into space slices that also have no spaceBoundary, where the outer one surrounds
			 * the inner ones.
			 */

			feature redefines isClosed = true;

			feature spaceBounder: Occurrence redefines self;

			outer: Occurrence [0..1] subsets spaceSlices {
				feature redefines isClosed = true;
				feature redefines innerSpaceDimension = spaceBounder.innerSpaceDimension;
			}

			inner: Occurrence [0..*] subsets spaceSlices {
				feature redefines isClosed = true;
				feature redefines innerSpaceDimension = spaceBounder.innerSpaceDimension;
			}

			inv { notEmpty(inner) implies notEmpty(outer) }
			inv { notEmpty(outer) implies
				contains(unionsOf, union(outer, inner)) }
		}

		feature spaceBoundaryOf: Occurrence[0..*] subsets spaceShotOf {
			doc
			/*
			 * An Occurrence of which this one is the space boundary.
			 */

			feature spaceBounderOf: Occurrence redefines self;
			inv { spaceBounderOf.spaceBoundary == that.that }
		}

		inv { not isClosed implies contains(self.unionsOf, union(spaceBoundary, spaceInterior)) }
		inv { innerSpaceDimension == 0 implies isEmpty(spaceBoundary) }

		connector :SurroundedBy
			from surroundingSpace references spaceBoundary.outer [1]
			to surroundedSpace references spaceInterior [0..*];

		connector :SurroundedBy
			from surroundingSpace references spaceInterior [1]
			to surroundedSpace references spaceBoundary.inner [0..*];

		feature innerSpaceOccurrences: Occurrence [0..*] {
			doc
			/*
			 * Occurrences that completely occupy the space surrounded by an inner space boundary of this Occurrence.
			 */
		}

		feature isClosed : Boolean [1] {
			doc
			/*
			 * Tells whether an occurrence has a spaceBoundary, true if it does, false otherwise.
			 */
		}
		inv { isClosed == isEmpty(spaceBoundary) }

		feature incomingTransfers: Transfers::Transfer[0..*] subsets Transfers::transfers {
			doc
			/*
			 * The incoming transfers received by this occurrence.
			 */

			end feature redefines source;
			end feature redefines target;
		}
		
		feature isDispatch : Boolean[1] default false {
			doc
			/*
			 * Determines whether transfers to the dispatch scope might be accepted more than once.
			 */
		}
 		feature dispatchScope: Occurrence [1] default self;
 		connector :HappensDuring from self[1] to dispatchScope[1];
 		
 		feature isRunToCompletion: Boolean [1] default true {
			doc
			/*
			 * Determines whether transition performances might happen during state entry performances
			 * within the run to completion scope.
			 */
		}
		feature runToCompletionScope: Occurrence [1] default self;
		connector :HappensDuring from self[1] to runToCompletionScope[1];
 
 		feature incomingTransferSort : IncomingTransferSort [0..*] default earlierFirstIncomingTransferSort {
			doc
			/*
			 * Determines which transfer to accept when multiple are available and which of the unaccepted 
			 * transfers are never to be accepted (dispatched).
			 */
		}

		feature all incomingTransfersToSelf subsets incomingTransfers {
			doc
			/*
			 * The incoming transfers with this occurrence as the target.
			 */

			end feature redefines source;
			end feature redefines target;
		}
		binding incomingTransfersToSelf.target = self;

		feature outgoingTransfers: Transfers::Transfer[0..*] subsets Transfers::transfers {
			doc
			/*
			 * The outgoing transfers sent from this occurrence.
			 */

			end feature redefines source;
			end feature redefines target;
		}

		feature all outgoingTransfersFromSelf subsets outgoingTransfers {
			doc
			/*
			 * The outgoing transfers with this occurrence as the source.
			 */

			end feature redefines source;
			end feature redefines target;
		}
		binding outgoingTransfersFromSelf.source = self;
	}

	abstract class all Life specializes Occurrence {
		binding portionOf = self {
			doc
			/*
			 * Lives are only portions of themselves.
			 */
			}
	}

	abstract feature occurrences: Occurrence[0..*] nonunique subsets things;
	
	predicate IncomingTransferSort specializes Performances::BooleanEvaluation {    
		in t1: Transfers::Transfer [1];
		in t2: Transfers::Transfer [1];  
		return t1First: Boolean [1]; 
	}

	bool earlierFirstIncomingTransferSort : IncomingTransferSort {
		return t1First = includes(t1.endShot.successors, t2.endShot);
	}

	assoc all SelfSameLifeLink specializes BinaryLink {
		doc
		/*
		 * SelfSameLifeLink is a binary association that is equivalent to SelfLink if the
		 * linked things are DataValues, but asserts that the link things are portions of
		 * the same Life if they are Occurrences. A SelfSameLink is not itself an Occurrence
		 * (SelfSameLifeLink is disjoint with LinkObject).
		 */

		end feature myselfSameLife: Anything[1..*] redefines source;
		end feature selfSameLife: Anything[1..*] redefines target;

		feature all sourceOccurrence : Occurrence [0..1] subsets myselfSameLife;
		feature all targetOccurrence : Occurrence [0..1] subsets selfSameLife, sourceOccurrence.sameLifeOccurrences;
		binding oSelf of sourceOccurrence.portionOfLife = targetOccurrence.portionOfLife;

		feature all sourceDataValue : DataValue [0..1] subsets myselfSameLife;
		feature all targetDataValue : DataValue [0..1] subsets selfSameLife;
		binding dSelf of sourceDataValue = targetDataValue;
	}

	subclassifier SelfLink specializes SelfSameLifeLink;

	assoc HappensLink specializes BinaryLink {
		doc
		/*
		 * HappensLink is the most general associations that assert temporal relationships between a
		 * sourceOccurrence and a targetOccurrence. Because HappensLinks assert temporal
		 * relationships, they cannot themselves be Occurrences that happen in time.  Therefore
		 * HappensLink is disjoint with LinkObject, that is, no HappensLink can also be a
		 * LinkObject.
		 */
		
		end feature sourceOccurrence: Occurrence[0..*] redefines BinaryLink::source;
		end feature targetOccurrence: Occurrence[0..*] redefines BinaryLink::target;
	}

	assoc HappensDuring specializes HappensLink {
		doc
		/*
		 * HappensDuring asserts that the shorterOccurrence happens during the longerOccurrence.
		 * That is, the time interval of the shorterOccurrence is completely within that of the
		 * longerOccurrence, or every snapshot of the shorterOccurrence happens while (at the
		 * same time as) some snapshot of the longerOccurrence. Note that this means every
		 * Occurrence HappensDuring itself and that HappensDuring is transitive.
		 */
		
		end feature shorterOccurrence: Occurrence[1..*] redefines sourceOccurrence subsets longerOccurrence.timeEnclosedOccurrences;
		end feature longerOccurrence: Occurrence[1..*] redefines targetOccurrence;

		/*
		 * HappensDuring and HappensBefore constrain each other. All predecessors of
		 * (occurrences happening before) a HappenDuring's longerOccurrence are also
		 * predecessors of its shorterOccurrence. Inversely, all successors (occurrences
		 * happening after) its longerOccurrence are also successors of its shorterOccurrence.
		 */

		subset longerOccurrence.predecessors subsets shorterOccurrence.predecessors;
		subset longerOccurrence.successors subsets shorterOccurrence.successors;

		subset shorterOccurrence.timeEnclosedOccurrences subsets longerOccurrence.timeEnclosedOccurrences;
	}

	assoc HappensWhile specializes HappensDuring {
		doc
		/*
		 * HappensWhile asserts that two occurrences happen during each other, that is, they
		 * each start at the same time and end at the same time.
		 */

		end feature thisOccurrence: Occurrence[1..*] redefines shorterOccurrence;
		end feature thatOccurrence: Occurrence[1..*] redefines longerOccurrence;

		connector :HappensDuring
			from shorterOccurrence references thatOccurrence [1]
			to longerOccurrence references thisOccurrence  [1];
	}

	assoc InsideOf specializes BinaryLink {
		doc
		/*
		 * InsideOf asserts that its largerSpace completely overlaps its smallerSpace in space (not
		 * necessarily in time, see HappensDuring). That is, all four dimensional points of the
		 * smallerSpace are in the spatial extent of the largerSpace. Note that this means every
		 * Occurrence is InsideOf itself and that InsideOf is transitive.
		 */

		end feature smallerSpace: Occurrence[1..*] redefines source, largerSpace.spaceEnclosedOccurrences;
		end feature largerSpace: Occurrence[1..*] redefines target;

		subset smallerSpace.spaceEnclosedOccurrences subsets largerSpace.spaceEnclosedOccurrences;

		inv { includes(largerSpace.timeEnclosedOccurrences, smallerSpace) implies (self istype Within) }
	}

	assoc all Within specializes HappensDuring, InsideOf {
		doc
		/*
		 * Within asserts that its largerOccurrence completely overlaps its smallerOccurrence in
		 * time and space. That is, all four dimensional points of the smallerOccurrence happen
		 * during and are included in the space of the largerOccurrence. This means every occurrence
		 * is Within itself and Within is transitive.
		 */

		end feature smallerOccurrence: Occurrence[1..*] redefines shorterOccurrence, smallerSpace
		  subsets largerOccurrence.spaceTimeEnclosedOccurrences;
		end feature largerOccurrence: Occurrence[1..*] redefines longerOccurrence, largerSpace;
	 }

	assoc WithinBoth specializes Within {
		doc
		/*
		 * WithinBoth asserts that two occurrences are Within each other, that is, they occupy the
		 * same four dimensional region.  Note that this means every Occurrence is WithinBoth with
		 * itself and transitive.
		 */

		end feature thisOccurrence: Occurrence[1..*] redefines smallerOccurrence
		  subsets thatOccurrence.spaceTimeCoincidentOccurrences;
		end feature thatOccurrence: Occurrence[1..*] redefines largerOccurrence
		  subsets thisOccurrence.spaceTimeCoincidentOccurrences;

		connector :Within
			from smallerOccurrence references thatOccurrence [1]
			to largerOccurrence references thisOccurrence [1];
	}

	assoc PortionOf specializes Within {
		doc
		/*
		 * PortionOf asserts one occurrence is a portion of another, including at least itself.
		 */

		end feature portionOccurrence: Occurrence[1..*] redefines smallerOccurrence subsets portionedOccurrence.portions;
		end feature portionedOccurrence: Occurrence[1..*] redefines largerOccurrence subsets portionOccurrence.portionOf;

		binding portionOccurrence.portionOfLife[1] = portionedOccurrence.portionOfLife[1];
	}

	assoc TimeSliceOf specializes PortionOf {
		doc
		/*
		 * TimeSliceOf asserts one occurrence is a time slice of another, including at least itself.
		 */

		end feature timeSliceOccurrence: Occurrence[1..*] redefines portionOccurrence subsets timeSlicedOccurrence.timeSlices;
		end feature timeSlicedOccurrence: Occurrence[1..*] redefines portionedOccurrence subsets timeSliceOccurrence.timeSliceOf;
	}

	assoc SnapshotOf specializes TimeSliceOf {
		doc
		/*
		 * SnapshotsOf asserts one occurrence is a snapshot of another.
		 */

		end feature snapshotOccurrence: Occurrence[1..*] redefines timeSliceOccurrence subsets snapshottedOccurrence.snapshots;
		end feature snapshottedOccurrence: Occurrence[0..*] redefines timeSlicedOccurrence subsets snapshotOccurrence.snapshotOf;
	}

	assoc SpaceSliceOf specializes PortionOf {
		doc
		/*
		 * SpaceSliceOf asserts that it spaceSliceOccurrence extends for exactly the same time and
		 * some or all the space of the spaceSlicedOccurrence and that the spaceSliceOccurrence is
		 * of the same of lower innerSpaceDimension than the spaceSliceOccurrence.  Note that this
		 * means every occurrence is a SpaceSliceOf itself and SpaceSliceOf is transitive.
		 */

		end feature spaceSliceOccurrence: Occurrence[1..*] redefines portionOccurrence subsets spaceSlicedOccurrence.spaceSlices;
		end feature spaceSlicedOccurrence: Occurrence[1..*] redefines portionedOccurrence subsets spaceSliceOccurrence.spaceSliceOf;

		inv { spaceSliceOccurrence.innerSpaceDimension <= spaceSlicedOccurrence.innerSpaceDimension }
	}

	assoc SpaceShotOf specializes SpaceSliceOf {
		doc
		/*
		 * SpaceShotOf asserts that its spaceShotOccurrence is of a lower inner space dimension than
		 * it spaceShottedOccurrence.
		 */

		end feature spaceShotOccurrence: Occurrence[1..*] redefines spaceSliceOccurrence subsets spaceShottedOccurrence.spaceShots;
		end feature spaceShottedOccurrence: Occurrence[1..*] redefines spaceSlicedOccurrence subsets spaceShotOccurrence.spaceShotOf;

		inv { spaceShotOccurrence.innerSpaceDimension < spaceShottedOccurrence.innerSpaceDimension }
	}

	assoc Without specializes BinaryLink {
		doc
		/*
		 * Without is the most general association that asserts complete separation (no overlap) in
		 * either space or time, or both, between two occurrences.  That is, no four dimensional
		 * points are in both occurrences. Note that this means no Occurrence is Without itself.
		 */

		end feature separateOccurrenceToo: Occurrence[0..*] redefines BinaryLink::source;
		end feature separateOccurrence: Occurrence[0..*] redefines BinaryLink::target;

		inv { separateOccurrenceToo != separateOccurrence }
	}

	assoc HappensBefore specializes HappensLink, Without {
		doc
		/*
		 * HappensBefore asserts that the earlierOccurrence is completely separated in time (not
		 * necessarily in space, see OutsideOf), with the earlierOccurrence happening completely
		 * before the laterOccurrence.	That is, no snapshot of the earlierOccurrence happens at the
		 * same time as any snapshot of the laterOccurrence, with all snapshots of earlierOccurrence
		 * happening before those the laterOccurrence, including the endShot of the earlierOccurrence
		 * and startShot of the laterOccurrence. Note that this means no Occurrence HappensBefore
		 * itself.
		 */

		end feature earlierOccurrence: Occurrence[0..*] redefines sourceOccurrence, separateOccurrenceToo subsets laterOccurrence.predecessors;
		end feature laterOccurrence: Occurrence[0..*] redefines targetOccurrence, separateOccurrence subsets earlierOccurrence.successors;

		/* HappensBefore is transitive. */
		subset laterOccurrence.successors subsets earlierOccurrence.successors;
	}

	assoc HappensJustBefore specializes HappensBefore {
		doc
		/*
		 * HappensJustBefore is HappensBefore asserting that there is no possibility of another
		 * occurrences happening in the time between the earlierOccurrence and laterOccurrence.
		 */

		end feature redefines earlierOccurrence: Occurrence[0..*] subsets laterOccurrence.immediatePredecessors;
		end feature redefines laterOccurrence: Occurrence[0..*] subsets earlierOccurrence.immediateSuccessors;

		disjoint earlierOccurrence.successors from laterOccurrence.predecessors;
	}

	feature happensBeforeLinks: HappensBefore[0..*] nonunique subsets binaryLinks {
		doc
		/*
		 * happensBeforeLinks is a specialization of binaryLinks restricted to type HappensBefore.
		 * It is the default subsetting for succession connectors.
		 */

		end feature earlierOccurrence: Occurrence[0..*] redefines HappensBefore::earlierOccurrence, binaryLinks::source;
		end feature laterOccurrence: Occurrence[0..*] redefines HappensBefore::laterOccurrence, binaryLinks::target;
	 }

	assoc OutsideOf specializes Without {
		doc
		/*
		 * OutsideOf asserts that two occurrences do not overlap in space (not necessarily in time,
		 * see HappensBefore).	That is, no four dimensional points of the occurrences are in the
		 * spatial extent of both of them. This means no Occurrence is OutsideOf itself.
		 */

		end feature separateSpaceToo: Occurrence[0..*] redefines separateOccurrenceToo;
		end feature separateSpace: Occurrence[0..*] redefines separateOccurrence;
	}

	assoc JustOutsideOf specializes OutsideOf {
		doc
		/*
		 * JustOutsideOf is an OutsideOf asserting that two occurrences have some space slices with
		 * no space between them.
		 */

		connector :MatesWith [1..*]
			from separateSpace references separateSpace.spaceSlices [0..*]
			to separateSpaceToo references separateSpaceToo.spaceSlices [0..*];
	}

	assoc MatesWith specializes JustOutsideOf {
		doc
		/*
		 * MatesWith is an OutsideOf asserting that two occurrences have no space between them.
		 */

		end feature matingSpaceToo: Occurrence[0..*] redefines separateSpaceToo
		  subsets matingSpace.matingOccurrences;
		end feature matingSpace: Occurrence[0..*] redefines separateSpace
		  subsets matingSpaceToo.matingOccurrences;
		feature inBetweenOccurrence: Occurrence [1] {
			portion feature redefines spaceBoundary [1];
			inv { contains(unionsOf, union(matingSpaceToo, matingSpace)) }
			portion feature redefines spaceInterior [0];
		}
	}

	assoc InnerSpaceOf specializes OutsideOf {
		doc
		/*
		 * InnerSpaceOf is an OutsideOf asserting that one occurrence (innerSpace) is the space interior
		 * of an occurrence (hOccurrence) formed from an inner space boundary of another occurrence (outerSpace). 
		 */

		end feature outerSpace: Occurrence[0..*] redefines separateSpaceToo;
		end feature innerSpace: Occurrence[0..*] redefines separateSpace subsets outerSpace.innerSpaceOccurrences {
			feature redefines innerSpaceOccurrences [0]; }

		feature hOccurrence: Occurrence [1];
			
		connector hbi: WithinBoth [0..1] from hOccurrence.spaceBoundary [0..1] to outerSpace.spaceBoundary.inner [0..1];
		connector hbo: WithinBoth [0..1] from hOccurrence.spaceBoundary [0..1] to outerSpace [0..1];
		connector :WithinBoth from hOccurrence.spaceInterior [1] to innerSpace [1];

		inv { (isEmpty(hbi) == notEmpty(hbo)) &
		      (notEmpty(hbo) == outerSpace.isClosed) }
	}

	assoc SurroundedBy specializes OutsideOf {
		doc
		/*
		 * SurroundedBy is an OutsideOf asserting that one occurrence (surrounded space) is included
		 * in space by an inner space occurrence of another (surrounding space).
		 */

		end feature surroundingSpace: Occurrence[0..*] redefines separateSpaceToo;
		end feature surroundedSpace: Occurrence[0..*] redefines separateSpace;

		connector :InsideOf
			from smallerOccurrence references surroundedSpace [0..1]
			to largerOccurrence references surroundingSpace.innerSpaceOccurrences [1..*];
	}
}
