// --- LICENSE ---
/**
Copyright 2026 CouchSurfing International Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
// --- LICENSE ---

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

/// Dart requires `Class<T>.named()`, not `Class.named<T>()`. [newInstance] on a
/// dotted [refer] puts type args in the wrong place.
Expression genericConstructorInvocation({
  required String className,
  required String? namedConstructorName,
  required Iterable<Expression> positionalArguments,
  required Map<String, Expression> namedArguments,
  required List<Reference> typeArguments,
}) {
  if (typeArguments.isEmpty) {
    final access = namedConstructorName == null || namedConstructorName.isEmpty
        ? className
        : '$className.$namedConstructorName';
    return refer(
      access,
    ).newInstance(positionalArguments, namedArguments, const []);
  }
  final target = TypeReference(
    (b) => b
      ..symbol = className
      ..types.addAll(typeArguments),
  );
  if (namedConstructorName == null || namedConstructorName.isEmpty) {
    return target.newInstance(positionalArguments, namedArguments, const []);
  }
  return target.newInstanceNamed(
    namedConstructorName,
    positionalArguments,
    namedArguments,
    const [],
  );
}

String publicParameterName(FormalParameterElement parameter) {
  final name = parameter.name ?? '';
  if (name == 'new') {
    return '';
  }

  return parameter.isNamed || parameter is SuperFormalParameterElement
      ? name.replaceAll(RegExp('^_+'), '')
      : name;
}

/// Super formals like `super.all` can report [dynamic] when the super
/// constructor uses a private field formal (`this._all`) — the analyzer does
/// not always link [SuperFormalParameterElement.superConstructorParameter].
DartType parameterElementType(FormalParameterElement parameter) {
  if (parameter is SuperFormalParameterElement) {
    final linked = parameter.superConstructorParameter;
    if (linked != null) {
      return linked.type;
    }

    final ctor = parameter.enclosingElement;
    final publicName = parameter.name;
    if (ctor is ConstructorElement && publicName != null) {
      final superCtor = ctor.superConstructor;
      if (superCtor != null) {
        for (final parentParam in superCtor.formalParameters) {
          if (publicParameterName(parentParam) == publicName) {
            return parentParam.type;
          }
        }
      }
    }
  }

  return parameter.type;
}

/// Raw [refer(type)] fails for type params — e.g. `E` is not in scope in the
/// generated `.g.dart` file. If we propagate the type param to the method
/// ([inScopeTypeParams]), use it; otherwise substitute the bound.
Reference typeToReference(
  DartType type, {
  Set<String> inScopeTypeParams = const {},
}) {
  if (type is TypeParameterType) {
    if (type.element.name case final name?
        when inScopeTypeParams.contains(name)) {
      return refer(name);
    }
    final bound = type.bound;
    if (bound is DynamicType) {
      return refer('Object');
    }
    return refer(bound.getDisplayString());
  }
  return refer(type.getDisplayString());
}

Reference parameterTypeReference(
  FormalParameterElement parameter, {
  Set<String> inScopeTypeParams = const {},
}) {
  return typeToReference(
    parameterElementType(parameter),
    inScopeTypeParams: inScopeTypeParams,
  );
}

/// Method must declare the type param so it's in scope for parameter types.
/// Preserves source bounds: unbounded (null/dynamic) stays unbounded.
Reference typeParameterToReference(TypeParameterElement tp) {
  final bound = tp.bound;
  return TypeReference((b) {
    b.symbol = tp.name ?? '';
    b.bound = switch (bound) {
      null || DynamicType() => null,
      final bound => refer(bound.getDisplayString()),
    };
  });
}
