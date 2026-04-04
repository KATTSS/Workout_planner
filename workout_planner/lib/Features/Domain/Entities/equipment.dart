class Equipment {
  String name;
  Equipment(this.name);
}

class Weight extends Equipment {
  double mass = 0.0;
  Weight(this.mass, {String name = 'dumpbell'}) : super(name);
}

class Machine extends Equipment {
  Weight weight;
  Machine(this.weight, {String name = "bench"}) : super(name);
}
